---
title: Finely Sliced User Stories
date: 2017-03-07
tags: process
---

After working in a team for over two years following XP principles there's one technique that stands out as being fundamental: **writing small user stories**. It's a cornerstone that supports and encourages other effective practices.

When a new feature or epic nears the product backlog horizon, before it can be worked on, user stories are needed to surface the detail. This step morphs a single line as short as "Password reset" or "Promotion discount codes" into a story from the user's perspective.

While either of these examples could be described within a single story, there are benefits to be gained from dividing the feature into smaller parts. Let's compare two approaches for the "Promotion discount codes" feature.

## The Elephant

### 1: Free delivery for first time customers
As a first-time customer I want to receive free delivery on my order.

<div class="story orange">
Given I've filled my shopping basket,<br>
And I am viewing my basket,<br>
When I enter the promotion code "WELCOME",<br>
Then I should see my basket total discounted by £4.99,<br>
And I should be charged the discounted amount.
<br><br>
Given I've already placed an order,<br>
And I've filled my shopping basket,<br>
And I am viewing my basket,<br>
When I enter the promotion code "WELCOME",<br>
Then I see a message stating the code cannot be used,<br>
And my basket total should remain the same.
</div>

## An alternative
This feature could be split into a set of five stories:

### 1: Reject invalid promotion codes
As a confused customer I am informed if a promotion code is invalid.

<div class="story">
Given I've filled my shopping basket,<br>
And I am viewing my basket,<br>
When I enter the promotion code "GIMME£",<br>
Then I see a message stating the code cannot be used.
</div>

### 2: Display the discount when a valid code is applied
As a customer I can apply a promotion code to my basket.

<div class="story">
Given I've filled my shopping basket,<br>
And I am viewing my basket,<br>
When I enter the promotion code "WELCOME",<br>
Then I should see my basket total discounted by £4.99.
</div>

### 3: Restrict the discount to first-time customers
As a return customer I am informed that I'm not eligible to receive this discount.

<div class="story">
Given I've already placed an order,<br>
And I've filled my shopping basket,<br>
And I am viewing my basket,<br>
When I enter the promotion code "WELCOME",<br>
Then I see a message stating the code cannot be used.
</div>

### 4: Apply the discount when charging the customer
As a customer I want to be charged the correct amount for my order.

<div class="story">
Given I've applied the promo code "WELCOME",<br>
When I place my order,<br>
Then I should be charged the discounted amount.
</div>

### 5: Update email receipts to show any discounts
As a customer I want my receipt to reflect the price paid.

<div class="story">
Given I've applied the promo code "WELCOME",<br>
And I've placed an order,<br>
When I check my email order receipt,<br>
Then I should see any discount amount,<br>
And a revised total including any discount.
</div>

## Correctness
I've had great discussions with people who wouldn't split the feature this way. Building up an approach to slicing stories varies according to personal taste, the feature itself, and what makes sense for your team. There are numerous ways to divide a feature and many of them will reach the desired outcome.

An illuminating exercise is sketching out several different cuts of the same feature. Grab a couple of colleagues and try whiteboarding variations of the same feature approached in different directions. Try to make each approach distinct as an experiment.

-  Try handling the failure case first (as per story #1 of the alternative above) before the 'happy-path' story for the success case. What happens to the remaining stories?
- Can you write each story as a releasable entity without making any one story too big?

## Let's compare
I've omitted some details and aspects of functionality from the elephant-sized story to keep it readable. It's an illustration of the 'big bang' approach to tackling the whole feature at once. You could (in)definitely keep writing requirements for the one giant story. Suddenly you're the owner of your very own mini waterfall with a specification document and a contents section.

Switching focus from the all-in-one story: **What do we gain from dividing what is notionally the same amount of work into smaller stories?**

Why make five 1-point stories over a single 5-point story?

### Faster feedback
Faster feedback is the primary benefit: When a developer has completed the first story, the product owner can review the nascent feature on a preview website or build (a.k.a the acceptance environment). This encourages frequent, piece-by-piece acceptance of the feature which in turn reveals potential issues sooner.

Perhaps after the first story there's a realisation that *"Oh yes, we forgot about a loading spinner while the promo code is validated"*. This extra detail could be rectified at the end of the feature development, but fixing the issue sooner is beneficial. A prompt correction means it's less likely to be observed and reported by multiple people, avoiding a recurring burden on the team.

Taking this point further, what if the potential issue is more critical? Seeing the groundwork of the feature sooner could lead the team to realise the screen is overloaded and needs to be rethought.

Fortunately being a team which exhibits agility *(remember — [Agile is Dead][agile-is-dead])*, there's the option of switching to another track of work while the checkout flow is reconsidered. If the entire feature had been delivered in one go, in its original guise, then more rework would be required and that's frustrating for everyone involved.

[agile-is-dead]: https://pragdave.me/blog/2014/03/04/time-to-kill-agile.html

Ultimately by dealing in smaller stories, less code is written before issues are realised and corrected.

### Shipping sooner
Working in smaller units also gives you the option to ship a feature to your users sooner. Releasing a first-cut which offers part of the anticipated functionality can still be valuable to users, even when there are further use cases which need to be covered.

Some features can't be shipped only partially complete; in our example releasing the promotion code feature without the fourth story to charge the correct amount to the credit/debit card is unacceptable. One might argue none of the preceding stories are legitimate given this.

It's still worth considering the split, even when the initial stories aren't releasable, because it allows faster internal feedback. If necessary the whole feature can be hidden until it's ready (a.k.a. feature-flagged) so that it won't be visible for your customers in production but remains available to internal testers.

### Momentum and limiting complexity
For the contributors working directly on the stories there are benefits from small stories too. There's less to keep in your head in one go. It feels less daunting to start just one aspect of the feature versus being overwhelmed with the whole thing at once.

Completing five stories — and picking up something 'new' each time — gives a feeling of momentum. This is especially true when big stories turn out to have hidden complexity and descend into a slog. These psychological benefits may not apply to all contributors, but I've found them valuable.

By considering smaller parts of the feature at a time we also allow for deeper thought about how the feature will work. This leads to more focused feedback back upstream to those in command of the product. For example, with the promotion code feature, the nuance of which error message to display if you've already used the code versus when the code is invalid.

**We all communicate with greater clarity when focusing on smaller units of work.**

### Opportunity to rotate
If one developer or a pair tackles the entire feature in a giant story then they're the gatekeepers of how the feature works in a technical capacity. Smaller stories make it easier for multiple contributors to work on a feature, either with a handover or through working in parallel.

Any handover can be perceived as detrimental to short term progress since more coordination is required, but reducing siloed knowledge has significant long term benefit. Rotation through a feature encourages greater distribution of knowledge and sharing of skills amongst the entire team.

## To recap
The benefits of keeping user stories small:

- Faster feedback cycles
- Uncovering issues sooner
- The option to release the base feature sooner
- Flexibility to reorganise the backlog if priorities change
- Limits complexity and mental burden for contributors

## Slicing technique
It takes time to build up instinct of how to divide stories for your team. It takes practice. There will be times when the stories seem fine at the point of being written, but immediately feel uncomfortable when read aloud to the team. Perhaps the stories then need to be rewritten but you'll have learnt from it.

Here a few considerations to keep in mind when slicing up a feature:

- Can each story be accepted without technical assistance? Avoid "Let me show you that in the database" acceptance wherever possible.
- Can you keep each story independently releasable without making any one story too large?
- Can you structure the stories so more developers can work on the feature at once?

<style>
.story {
  position: relative;
  padding: 0.8em 1.2em;
  margin: 1em auto;
  color: #fff;
  background: #36B1BF;
  line-height: 1.6em;
}

.story:before {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  border-width: 0 1em 1em 0;
  border-style: solid;
  border-color: #309CA8 #fff;
}

.story.orange {
  background: #F5A503;
}

.story.orange:before {
  border-color: #DB9403 #fff;
}
</style>
