---
title: Restraining Oneself From Dependency Hell
date: 2019-06-20
---

The advice to [Kill Your Dependencies][kyd] has many merits. Transitive
dependencies which contain pessimistic version constraints for their own
dependencies are a major headache. These constraints block you from updating
shared dependencies when you *want to* — and become a nightmare when you **have
to** update to receive a critical security patch.

[kyd]: http://www.mikeperham.com/2016/02/09/kill-your-dependencies/

Despite the common due diligence checklist for selecting dependencies (Is it
still receiving updates? Are PRs merged? Are there tests / CI?) I think it's
fair to say most developers don't routinely check transitive dependencies with
the same rigour.

Overall dependency management is a tricky beast. It's not ideal to reinvent the
wheel, yet it's shortsighted to include huge or poorly maintained dependencies
which you may only use a fraction of.

## Practising What You Preach

Recently I've been working on a project which has benefitted greatly from
parameterized testing (a.k.a table tests) to concisely verify business logic
with a variety of inputs.

### The Original Incarnation

Originally these tests were implemented with a humble array of arrays and
`#each` like so:

```ruby
RSpec.describe "my complex business logic" do
  [
    ["2019-06-05", "weekly",    "2019-06-13"],
    ["2019-06-05", "bi-weekly", "2019-06-20"],
    ["2019-06-05", "monthly",   "2019-07-13"],
  ].each do |today, schedule, expected_date|
    it "determines the next appointment date" do
      result = NextAppointmentCalculator.new.process(today, schedule)
      expect(result).to eq expected_date
    end
  end
end
```

This approach is simple and introduces no extra dependencies, but the
readability isn't optimal; the parameter names are after the data - so you have
to read the lines in an unnatural order.

### Fancy. But no.

I found a library called [`RSpec::Parameterized`][rspec-parameterized]. The
resulting test reads well:

[rspec-parameterized]: https://github.com/tomykaira/rspec-parameterized

```ruby
RSpec.describe "my complex business logic" do
  where(:today, :schedule, :expected_date) do
    [
      ["2019-06-05", "weekly",    "2019-06-13"],
      ["2019-06-05", "bi-weekly", "2019-06-20"],
      ["2019-06-05", "monthly",   "2019-07-13"],
    ]
  end

  with_them do
    it "determines the next appointment date" do
      result = NextAppointmentCalculator.new.process(today, schedule)
      expect(result).to eq expected_date
    end
  end
end
```

Now the parameter names precede the values. This gem even includes a somewhat
terrifying table-style syntax:

```ruby
using RSpec::Parameterized::TableSyntax

where(:today, :schedule, :expected_date) do
  "2019-06-05" | "weekly"    | "2019-06-13"
  "2019-06-05" | "bi-weekly" | "2019-06-20"
  "2019-06-05" | "monthly"   | "2019-07-13"
end
```

But at what cost? Well, its dependencies include:

```
rspec-parameterized (0.4.2)
  binding_ninja (>= 0.2.3)
  parser
  proc_to_ast
  rspec (>= 2.13, < 4)
  unparser
```

And those new dependencies require:

```
parser (2.6.3.0)
  ast (~> 2.4.0)
proc_to_ast (0.1.0)
  coderay
  parser
  unparser
unparser (0.4.5)
  abstract_type (~> 0.0.7)
  adamantium (~> 0.2.0)
  concord (~> 0.1.5)
  diff-lcs (~> 1.3)
  equalizer (~> 0.0.9)
  parser (~> 2.6.3)
  procto (~> 0.0.2)
```

Run for the hills.

### Happy medium?

I ended up creating a micro-DSL and releasing it as a gem called
[`RSpec::WithParams`][rspec-with-params]. It allows you to write tests like
this:

[rspec-with-params]: https://github.com/odlp/rspec-with_params

```ruby
RSpec.describe "my complex business logic" do
  extend RSpec::WithParams::DSL

  with_params(
    [:today,        :schedule,    :expected_date],
    ["2019-06-05",  "weekly",     "2019-06-13"],
    ["2019-06-05",  "bi-weekly",  "2019-06-20"],
    ["2019-06-05",  "monthly",    "2019-07-13"],
  ) do
    it "determines the next appointment date" do
      result = NextAppointmentCalculator.new.process(today, schedule)
      expect(result).to eq expected_date
    end
  end
end
```

This solution fixes my main bugbear with the plain array of arrays approach -
I'd like the parameter names above the values - without introducing a ton of
dependencies.

Perhaps this is still the wrong option. It's an extra dependency. The answer could
be to stick with the first option and use plain Ruby. Alternatively, you may
want to avoid the single extra dependency and keep the readability benefit by
vendoring the helper function - it's [only ~14 lines of code][with-params-code].

[with-params-code]: https://github.com/odlp/rspec-with_params/blob/795c721ca6fcfdc4cc6443409421ea410f023cce/lib/rspec/with_params/dsl.rb#L6-L19)
