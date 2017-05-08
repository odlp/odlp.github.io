---
title: Reworking Tests for Future You
date: 2017-05-08
tags: tdd
---

**A journey in search of helpful failure messages and maintainable test structure.**

Pairing with a colleague last year we worked on a feature which required parsing recipes from a JSON file. The resulting production code felt natural and well considered after working in a familiar red-green-refactor approach.

<p>
<em>Ship it.</em><br>
<em>Done.</em><br>
<em>Next story.</em>
</p>

Hang on! Our creation had an unloved side. The happy-path tests — covering the anticipated path with no errors — were easy to read and described how the feature was intended to work. In contrast the error handling tests were comprehensive (covering all branches) but far from intelligible.

The error-cases were expressed through two specs; one for missing values and another for invalid values. Each scenario had an accompanying JSON fixture file. Each spec eventually contained assertions for several required fields.

During development the JSON fixture files began as an array containing one invalid JSON object and a red test, then the code to pass the test was written. As the cycle was repeated, a new invalid JSON object to the fixture file each time — **this was a mistake**.

Here's an abridged model, similar to the original:

```go
type Recipe struct {
	ID          string
	Title       string
	CookingTime int
}
```

An excerpt of the test:

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

And the JSON fixture file with an array with 4 invalid examples:

```json
{
  "recipes": [
    {},
    {
      "attributes": {}
    },
    {
      "attributes": {
        "title": "Tasty Potatoes"
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

This structure succeeded in building out the feature but it left ample room for improvement. The hit list of problems include:

### 1: Implicit assertion

The test *implies* all the invalid records have been skipped by asserting the return list is empty. The weak assertion also produces a terrible error message on failure:

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

If the validation breaks then an incomplete model is returned by the parser. In this case a recipe with an empty title. Our failure message states a list which is expected to be empty has a value present — that's a very murky failure.

### 2: Fragile

Each JSON object in the fixture file builds up the required recipe fields one by one, to pass as far as the next validation rule in the implementation.

This means the fixture file is tied to the sequence in which the recipe fields are validated. If the production code is reordered, although the tests will still pass, it decreases coverage because of the poor test structure (parsing of each invalid model would halt earlier than intended).

### 3: Unclear

The fixture file's omission of each required field was understood at the time of writing, but isn't communicated clearly for future readers and maintainers.

If another contributor stumbled across this test failing they'd most probably have to read the test, the fixture, and the production code to figure out why it was now failing. As one of the original authors, I'd also struggle to recall this information as time passes.

This vagueness adds time and unnecessary mental overhead to figuring out whats gone wrong in the event of a future bug. The failure of this test wants to be crystal clear. Then the valiant fixer-to-be can start looking HOW to fix it, with less head-scratching and context gathering needed on the way.

## Time for a rethink

The first step was to restructure the `RecipeParser` to focus on a single recipe entity, pushing the iteration over each raw value & mapping the parsed values to a higher-level.

The next step was breaking out **an example per validation rule**. One test for each required field. This was avoided this the first time round because it felt verbose — but it's not a valid reason and this false concern lead to heavily overloaded tests.

While splitting out the original two tests, it felt correct that each fixture should be otherwise complete, apart from the recipe field under examination:

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

This feels like progress. This step makes comprehension easier since the **input is right next to the test**. The reader doesn't have to fumble with finding and loading the fixture file in an adjacent editor pane to read the test.

Another benefit of the new test structure is the failure message is clearer:

```
• Failure [0.001 seconds]
RecipesParser
	missing required recipe fields
		returns an error if the title is missing [It]

		Expected an error, got nil
```

Satisfied with these improvements and after a quick git pit-stop to commit them, it was time to carry on developing the feature — there were another 10 or so attributes to parse. Moving on to the next required field exposed a hidden cost of the new test structure...

## A tedious side effect

When new validation rules and specs are added, all the other specs in the context needed updating. If the validation of a new recipe field was placed first in the implementation, it would break all the other validation tests because their JSON strings don't contain the new required field.

Alternatively if the new validation rule is added at the end of the implementation the other tests wouldn't fail in that moment. The downside is the tests regress to knowing exactly which recipe fields need to be present to reach the particular validation rule they are focused on — the same problem as before.

It's reasonable to believe the test shouldn't influence the inner workings of the production code. Tests are present to assert on the output or outcome of that code, and define their subject's interface. The sequence in which recipe fields are parsed doesn't matter in this use case.

### The final hurdle?

Overall the new structure of these tests with an assertion per recipe field felt like an improvement. The remaining issue was solely tied to keeping the fixture for each test in the correct state. This realisation led us to create builder to generate the fixture JSON for each test.

The builder allowed generation of valid JSON, or invalid JSON using a flag to omit a specified recipe field:

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

Using a builder there's no need to touch any of the other validation tests when adding a new recipe field. By updating the builder the existing tests receive the new fields. The tests are now isolated from one another.

I think this isolation alone is worth the trade-off of creating a builder for this particular spec. The builder itself could have a bug or develop a regression, which then invalidates or confuses the test where the built JSON is consumed. Fortunately some of that risk can be mitigated by writing a test for the builder.

## Finishing touches

Finally, the cherry on top. The builder approach offers the chance to restructure all the tests relating to the required fields as a [table test](https://onsi.github.io/ginkgo/#table-driven-tests). All the examples and expected values can share the same test function, which cuts down on the repetition each test had before.

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

## Recap

Personally this made me think about:

- Writing tests with clearer failure messages.

- Keeping raw input alongside the test whenever practical. Tests are easier to read when the input is inline or nearby.

- Being open to writing complex(-ish) helpers like a JSON builder which are only used in the tests. Even if this leads to "tests for test helpers" as a sanity check.
