---
title: Reworking Tests for Future You
date: 2017-05-06
tags: tdd
---

**A journey in search of helpful failure messages and maintainable test structure.**

Pairing with a colleague last year, we built up tests to tease out production code — working in familiar red-green-refactor fashion. The feature required parsing recipes from a JSON file. The resulting production code felt natural and well considered.

<p>
<em>Ship it.</em><br>
<em>Done.</em><br>
<em>Next story.</em>
</p>

Hang on one moment! Our creation had an unloved side. The happy-path tests — covering the anticipated path with no errors — were easy to read and described how the feature works, at least to our combined four eyes. In contrast the error handling tests were comprehensive (covering all branches) yet far from comprehensible.

The error-cases were tested with two specs; one for missing values and another for invalid values. Each scenario had an accompanying JSON fixture file. The poor tests grew during development and now grouped the checks for several required fields together.

In the process of developing this feature the fixture files started out with one invalid example and a red test, then the code to pass the test was written. As the cycle was repeated, we added a new invalid case to the fixture file each time — **this was a mistake**.

Here's an abridged version of the model we were trying to populate values for:

```go
type Recipe struct {
	ID          string
	Title       string
	CookingTime int
}
```

Here's an excerpt of the test:

```go
Context("missing required recipe fields", func() {
	It("skips over the invalid recipes", func() {
		fixture := "../test_data/missing_attributes_recipes.json"
		b, err := ioutil.ReadFile(fixture)
		Expect(err).ToNot(HaveOccurred())

		recipes, err := p.ParseRecipes(string(b))

		Expect(err).ToNot(HaveOccurred())
		Expect(recipes).To(HaveLen(0))
	})
})
```

And the fixture file with an array with 5 invalid examples:

```json
{
	"recipes": [
		{},
		{
			"attributes": null
		},
		{
			"attributes": {
				"title": "Tasty Potatoes"
			}
		},
		{
			"attributes": {
				"recipe_id": "112233-R"
			}
		},
		{
			"attributes": {
				"title": "Tasty Potatoes",
				"recipe_id": "112233-R"
			}
		}
	]
}
```

It works. But there was a lot of room for improvement. The hit list of problems include:

### 1: Implicit assertion

By checking the return list is empty we *imply* all the invalid records have been skipped. Also multiple validations are all mixed up in one test. The weak assertion also produces a terrible error message on failure:

```
• Failure [0.001 seconds]
RecipesParser
	missing required recipe fields
		skips over the invalid recipes [It]

		Expected
				<[]model.Recipe | len:1, cap:1>: [
						{
								ID: "112233-R",
								Title: "",
								CookingTime: 10,
						},
				]
		to have length 0
```

If the validation breaks then an incomplete model is returned by the parser, in this case a recipe with an empty title. Our failure message states a list which is expected to be empty has a value present. That's a very murky failure.

### 2: Fragile

Each JSON object in the fixture file builds up the required fields one by one, to pass as far as the next validation rule in the implementation. This means the fixture is tied to the order in which fields are validated. If the production code is reordered, then despite being valid, we may lose test coverage because some test examples drop off earlier than anticipated during validation. It's easy to end up not testing every field by mistake.

### 3: Unclear

The fixture's omission of each required field was clear at the time of writing, but this isn't communicated clearly for future readers and maintainers. We as the original authors will also struggle to recall this information as time passes.

If another contributor stumbled across this test failing they'd most probably have to read the test, the fixture, and the production code to figure out why it was now failing. This vagueness is adding time and unnecessary mental overhead to figuring out whats gone wrong.

Ideally the failure of this test should be crystal clear. Then if the test fails in the future, the valiant fixer-to-be can start looking HOW to fix it, with less head-scratching and context gathering needed on the way.

## Time for a rethink

The first step was to restructure the `RecipeParser` to focus on a single recipe entity, pushing the iteration over each raw value & mapping the parsed values to a higher-level.

The next step was to break out **an example per validation rule**. One test for each required field. We'd avoided this the first time round because it felt verbose — but it's not a valid reason and this false concern lead to overloaded tests.

While splitting out the tests, it felt correct that each fixture should be otherwise complete apart from the field under test.

```go
Context("missing required recipe fields", func() {
	It("returns an error if the title is missing", func() {
		rawJSON := `{
			"attributes": {
				"recipe_id": "112233-R",
				"cooking_time": 30
			}
		}`

		json, err := nosj.ParseJSON(rawJSON)
		Expect(err).ToNot(HaveOccurred())

		_, err = p.ParseRecipeJSON(json)
		Expect(err).To(MatchError("Missing title for recipe"))
	})

	It("returns an error if the ID is missing", func() {
		rawJSON := `{
			"attributes": {
				"title": "Tasty Potatoes",
				"cooking_time": 30
			}
		}`

		json, err := nosj.ParseJSON(rawJSON)
		Expect(err).ToNot(HaveOccurred())

		_, err = p.ParseRecipeJSON(json)
		Expect(err).To(MatchError("Missing id for recipe"))
	})

	// ... abridged
})
```

Now we are making progress. This step makes comprehension easier since the **input is right next to the test**. The reader doesn't have to fumble with finding and loading the fixture file in an adjacent editor pane to read the test.

While the inline JSON may be a subjective improvement, one benefit we have gained over the previous tests is the new structure. If one of these tests fails the failure message is vastly improved:

```
• Failure [0.001 seconds]
RecipesParser
	missing required recipe fields
		returns an error if the title is missing [It]

		Expected an error, got nil
```

Content with these improvements and after a quick git pit-stop to commit them, it was time to carry on developing the feature — there were another 10 or so attributes to parse. Moving on to the next required field exposed a hidden cost of the new test structure...

## A tedious side effect

When a new validation rules and specs are added, all the other specs in the context needed to be updated. If the validation of the new field was placed first in the implementation, it would break all the other validation tests because they don't have the new required field.

Alternatively if the new validation rule is added at the end of the implementation the other tests wouldn't fail today. The downside then is we're not guiding the author of the next test to keep the fixtures for the other tests in an 'almost complete' state (valid except the field in question). The tests can then easily regress to knowing exactly which fields need to be in the JSON to reach the particular validation rule they are focused on — the same problem we had before.

The test shouldn't influence the inner workings of the production code. The tests are there to assert on the output or outcome of that code, and define the subject's interface. The sequence in which fields are read doesn't matter in this use case.

Overall the new structure of these tests with an assertion per field felt like an improvement. The remaining issue was solely tied to keeping the fixture for each test in the correct state. This realisation led us to create builder to generate the fixture JSON for each test. We could now use this to build valid JSON or set a flag to strip out a specified field:

```go
// Building valid JSON:
defaultConfig := RecipeBuilderConfig{}
validRecipeJSON := RecipeJSONBuilder{}.Build(defaultConfig)

// Building JSON missing the title field:
missingTitleConfig := RecipeBuilderConfig{
		Title: Flag{Missing: true},
}
missingTitleJSON := RecipeJSONBuilder{}.Build(config)
```

The real benefit here is when adding further tests about a new field. With a builder we no longer have to touch a single character of the other validation tests. They're isolated from one another and by updating the builder they receive the new fields by default.

I think this isolation alone is worth the trade-off of creating a builder for this particular spec. The builder itself could have a bug or develop a regression, which then invalidates or confuses the test where the built JSON is consumed. Fortunately we can mitigate some of that risk by writing a test for the builder itself.

Finally, the cherry on top is that this approach offers the chance to restructure all the tests relating to the required fields as a [table test](https://onsi.github.io/ginkgo/#table-driven-tests). All the examples & expected values can share the same test function, which cuts down on the repetition each test had before.

```go
parseRecipeAndAssertError := func(expectedError string, config RecipeBuilderConfig) {
	builtJSON := RecipeJSONBuilder{}.Build(config)
	recipeJSON, err := nosj.ParseJSON(builtJSON)
	Expect(err).ToNot(HaveOccurred())

	_, err = RecipesParser{}.ParseRecipeJSON(recipeJSON)

	Expect(err).To(HaveOccurred())
	Expect(err.Error()).To(ContainSubstring(expectedError))
}

DescribeTable("error when missing attribute:",
	parseRecipeAndAssertError, // our test function
	Entry(
		"title",
		"Missing title for recipe.",
		RecipeBuilderConfig{Title: Flag{Missing: true}},
	),
	Entry(
		"ID",
		"Missing id for recipe.",
		RecipeBuilderConfig{ID: Flag{Missing: true}},
	),
	// and so on...
)
```

### In summary

Personally this made me think about:

- Focusing on writing clearer failure messages.

- If there's a raw input or fixture, keep it alongside the test whenever practical. Tests are easier to read when the input is inline or nearby.

- Not being shy of writing complex(-ish) helpers like a JSON builder which are only used in the test world. Even if this leads to "tests for tests" as a sanity check that the helper.
