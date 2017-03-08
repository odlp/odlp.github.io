---
title: Finely sliced user stories
date: 2017-03-07
tags: process
---

After working in a team for over two years following XP principles there's one technique which stands out as being fundamental amongst the many practices I learnt: **small user stories**. It's a cornerstone which supports and encourages many other effective practices.

As a new feature or epic nears the horizon of the product backlog it's time to add detail so work can commence. This means expanding a single line such as 'Password reset' or 'Promo discount codes' into user requirements. While either of these features could be packaged into a single story there's a lot to be gained from dividing the feature up into smaller parts. Let's compare two approaches for the 'Promo discount codes' feature.

## The Elephant

### 1: Free delivery for first time customers
As a first-time customer I want to receive free delivery on my order.

Given I've filled my shopping basket,
And I am viewing my basket,
When I enter the promotion code "WELCOME",
Then I should see my basket total discounted by £4.99,
And I should be charged the discounted amount.

Given I've already placed an order,
And I've filled my shopping basket,
And I am viewing my basket,
When I enter the promotion code "WELCOME",
Then I see a message stating the code cannot be used,
And my basket total should remain the same.

## An alternative
This feature could be split into a set of five stories:

### 1: Reject invalid promotion codes
As a confused customer I am informed if a promotion code is invalid.

Given I've filled my shopping basket,
And I am viewing my basket,
When I enter the promotion code "GIMME£",
Then I see a message stating the code cannot be used.

### 2: Display the discount when a valid code is applied
As a customer I can apply a promotion code to my basket.

Given I've filled my shopping basket,
And I am viewing my basket,
When I enter the promotion code "WELCOME",
Then I should see my basket total discounted by £4.99.

### 3: Restrict the discount to first-time customers
As a return customer I am informed that I'm not eligible to receive this discount.

Given I've already placed an order,
And I've filled my shopping basket,
And I am viewing my basket,
When I enter the promotion code "WELCOME",
Then I see a message stating the code cannot be used.

### 4: Apply the discount when charging the customer
As a customer I want to be charged the correct amount for my order.

Given I've applied the promo code "WELCOME",
When I place my order,
Then I should be charged the discounted amount.

### 5: Update email receipts to show any discounts
As a customer I want my receipt to reflect the price paid.

Given I've applied the promo code "WELCOME",
and I've placed an order,
When I check my email order receipt,
Then I should see any discount amount,
And a revised total including any discount.

## 'Correctness'
Some people wouldn't split the feature this way. Developing an approach to slice stories varies according to personal taste, the feature itself, and what makes sense for your team. There are many ways to divide a feature and most of them will reach the desired outcome.

An illuminating exercise is sketching out several different cuts of the same feature. Grab a couple of colleagues and try whiteboarding variations of the same feature approached in different directions. Try and make each of the approaches distinct as a experiment.

-  Try handling the failure case first (as per story #1 of the alternative above) before the story for the 'happy path' success-case. What happens to the remaining stories?
- Can you write each story as a 'releasable' entity without making any one story too big?

## Let's compare
I've omitted some details and aspects of functionality from the elephant-sized story to keep it readable. It's an illustration of the 'big bang' approach to developing the whole feature at once. You could (in)definitely keep writing requirements for the one story. Suddenly you're the owner of your very own mini waterfall with a specification document and a contents section.

Switching focus from the all-in-one story: **What do we gain from dividing what is notionally the same amount of work into smaller stories?**

Why make five '1 point' stories over a single '5 point' story?

### Faster feedback
Faster feedback is the number one benefit. When a developer has completed the first story the product owner can review the work in the acceptance environment. This encourages frequent, piece-by-piece acceptance of the feature which in turn allows potential issues to be recognised sooner.

Say after the first story there's that realisation that "Oh yes, we did forget about a loading spinner while the promo code is validated". This small detail can be corrected at the end of all the stories, but fixing the issue sooner could be efficient. Maybe a designer can assess how that UI element should work today since they are available.

Taking this point further, what if the potential issue is more critical? Seeing the groundwork of the feature sooner may lead the team to realise the screen is overloaded and needs to be rethought. It isn't desirable to pause development of the feature but the development team could switch to another track while the checkout flow is redesigned. If the entire feature had been delivered at once there would be more frustration to come since rework is inevitable. Ultimately with smaller stories less code is written before issues are recognised.

### Shipping sooner
Working in smaller units gives you the option to ship a feature to users sooner. Certain features can't be shipped only partially complete - in our example releasing promotion codes without the fourth story to charge the correct amount to the credit/debit card is unacceptable. One might argue none of the preceding stories are legitimate given this. It's still worth considering the split because it allows faster internal feedback. The entire feature can be hidden until it's ready (a.k.a. feature-flagged) so that it won't be visible for customers in production but remains available to internal testers.

There's still an early shipping advantage from these stories. Say you're developing a mobile application. Apple review each app release and this can impact how quickly a feature can be delivered to real users. Imagine stories one to four have been signed off in the internal acceptance environment. Whilst the final story about the email receipt is still being worked on a new release can be pushed to Apple for review. The structure of these stories gives you the flexibility to enact any slow moving parts of the release process sooner.

### Limiting complexity
For the contributors working directly on the stories there are benefits from small stories too. There's less to keep in your head in one go. It's less daunting to start just one aspect of the feature compared to being overwhelmed with the whole thing at once. Even the feeling of momentum from completing five stories (and picking up something 'new' each time) can give an uplift compared to a big story. Especially when big stories turn out to have hidden complexity and descend into a slog. These psychological benefits may not apply to all contributors but I've found them valuable.

As a contributor when you can consider smaller parts of the feature at a time it allows for deeper thought about how the feature will work. This can lead to more focused feedback back upstream to the product development team. For example with the promotion code feature, the nuance of which error message to display if you've already used the code compared to when the code is invalid. We can all communicate with greater clarity and in more depth when we're focusing on smaller units of work.

### Opportunity to rotate
If one developer or a pair tackles the entire feature in a giant story then you've missed an opportunity. With smaller stories it opens up the possibility of multiple contributors working on a feature (either handing over after each one or through work in parallel). This could be perceived as detrimental to short term progress because there's handover and more coordination required, but this is nothing compared to the significant long terms benefits like reducing siloed knowledge. It also encourages greater distribution of knowledge and skills amongst the entire team.

## To recap
The benefits of keeping user stories small:

- Faster feedback cycles
- Uncover issues sooner
- Option to release the base feature sooner
- Flexibility to reorganise the backlog if priorities change
- Limits complexity and mental burden for contributors

## Slicing technique
It takes time to build up instinct on how to divide stories for your team. Every skill takes practice. There will be times when at first the stories seem fine but when shared with the team they immediately feel uncomfortable. Perhaps the stories then need to be rewritten but you'll have learnt from it.

Here a few considerations to keep in mind when slicing up a feature:

- Can each story be accepted without technical assistance? (Avoiding "Let me show you that in the database" wherever possible.)
- Can you keep each story independently releasable without making any one story too large?
- Can you structure the stories so more developers can work on the feature at once?
