# What to look at first

Check out `spec/integration_test_spec.rb`. It gives you a good idea of what
the accounting API I created looks like in action, and plays out one of the
scenarios outlined in the problem description.

# About the code

I decided to implement this solution as a Rails project. There are only three
folders with code:

* `app/models` contains the building blocks of the system: Loans, accounting buckets (to keep track of, e.g., interest and principal separately) and accounting activities (more on that below)
* `app/interactors` contains all the business logic. Structuring it this way may or may not be controversial: I recognize that many Rails developers would put much of it inside the models, but I find that that leads to incredibly bloated models. So I separated every use-case out into its own interactor.
* `lib` - Mostly utility stuff that could be extracted into separate gems, as well as important accounting algorithms (which, again, I don't want to put on the models).

# Why did I do it this way?

Accounting is really, really, really hard, which is to say, it's really, really
really easy to mess up. Thus, in my experience, having a clear, chronological
record of every accounting activity is crucial - without it, it's impossible to
retrace your steps and figure out how you got here from the starting state. So
I chose to persist every activity in the database, including recurring ones like
being charged interest every day. I can then run accounting logic that tells me,
for a given day, how my balances changed by looking at the relevant activities.

Also, if I had more time to work on this, I'd implement double-entry bookkeeping.
