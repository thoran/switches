# Switches Roadmap

Date: 20260817

Not listed in the gemspec, so it does not ship with the gem.

## Design philosophy

Switches is a wrapper around OptionParser which is also the store for what was
parsed, and those two jobs meet on one object. Every question the library has had
to answer since 0.11.0 is the same question: which names does a `Switches`
instance own?

A name can be answered by the instance's own methods, by a declared switch
through `#method_missing`, or by the wrapped `OptionParser`. The rule arrived at
is that the program's own declarations beat the wrapper's interface, that the
instance's real methods beat both because Ruby dispatches to them first, and that
the names Ruby may call implicitly belong to nobody and are answered by the
settings. Where a name would be lost, the declaration is refused rather than
accepted.

## Current state: 0.13.0

### 0.10.4 (2026-08-16): ostruct as a declared dependency

0.10.0 had met Ruby 4.0's removal of ostruct from the default gems by requiring
it through a vendored `require_gem`, which rescues the LoadError and shells out
to `gem install`. That is worse than the plain require it replaced: the
dependency goes unannounced and is satisfied silently into whatever `GEM_HOME` is
set, which under a Homebrew formula's wrapper means the program installing a gem
into its own keg after the build. It also defeats the test, loading appearing to
succeed when what happened was an install mid-require.

A library should announce what it needs and fail loudly without it. Installing
gems behind the caller's back belongs in an executable at most.

### 0.10.5 (2026-08-16): a fix which turned out not to be needed

The proposal was that `#on_args` builds the switch string from the attribute
symbol verbatim, so `s.boolean(:update_template)` could only ever offer
`--update_template`, and that both forms should be emitted.

The premise was false. OptionParser files a long switch under a lookup key with
its underscores turned to hyphens, and converts whatever is supplied the same way
before the lookup, so the two spellings have always been one switch. The line is
present in 2.7.8's optparse, which is the gemspec's floor, and the behaviour was
confirmed under 2.7.8, 3.4.9, 4.0.0 and 4.0.5. Written against the *unmodified*
0.10.4 library, every parsing spec passed.

So the release added nothing. It pinned the inherited behaviour in specs, which
would now fail here rather than in a caller's script were optparse to change it,
and documented where it comes from. Only the missing-switch message changed, to
name the hyphenated form.

The mistake is worth keeping: it came of reading `#on_args` and stopping there.
The string handed to `OptionParser#on` is not the lookup key; optparse derives
the key from it, and nothing in this library shows that. The claim was about
behaviour, and behaviour is cheap to run.

### 0.11.0 (2026-08-16): forwarding to OptionParser

`#method_missing` compared `method_name.to_s` against `@op.methods`. Under Ruby
1.8, where `methods` returned Strings, that matched; from 1.9 it returns Symbols
and the branch could never be true. The line dates to 2009-12-22 and was never
touched, so the forwarding was dead for at least thirteen years — every call fell
through to the settings, and `s.banner = '...'`, documented in the README,
silently became a setting while the parser kept its default.

The header comment written the same day recorded the worry: *"I'm not sure that
this is wise, since in a way I've lost some control over the interface and
polluted the 'namespace' for potential switch names."* It never came due, because
the mechanism that would have made it bite stopped working within a couple of
years.

Two decisions followed from turning it on. A declared switch takes precedence
over the OptionParser method of the same name, the parser having `version`,
`help`, `release`, `load` and `order` among its 61 — without that rule, making
the forwarding work would shadow switches a program would reasonably want.
And `NEVER_FORWARDED` excludes the names Ruby may call implicitly, because the
forwarded set is built by subtraction — everything the parser responds to, less
everything `Switches` defines — which admits any such name `Switches` does not
happen to define. `OptionParser#to_a` answers with the help, so without the
exclusion `Array(switches)` and `[*switches]` did too. `to_h` was never at risk
only because `Switches` defines it; the constant makes that deliberate rather
than incidental.

Turning on a set which had never been consulted, because nothing could read it,
is where that came from. The dead branch meant the set's contents had never
mattered.

The set is memoised for the same reason it had gone unexamined. Every settings
read arrives through `#method_missing`, so the difference of two method lists was
being computed on each one, and nothing had ever depended upon the answer.

### 0.12.0 (2026-08-17): refusing a colliding switch name

`#method_missing` fires only where no method exists, so a switch named after a
method the instance already has parses, stores its value, and is then answered by
the method. `s.set(:tap)` leaves `#tap` as `Kernel#tap`, which without a block
raises `LocalJumpError` at the reading site. Others are worse for not raising —
`#display` prints and returns nil, `#hash` gives an Integer, `#class` gives
Switches.

Refusing the declaration was chosen over defining a real reader per switch, which
would make the collision an override rather than a loss but shadows core methods
on the object, and is the larger change. A program with such a switch cannot
work, so refusing to start it loses nothing, and the declaration is where the
mistake is.

Three corrections to the proposal, each found by measuring:

- **The receiver.** `Object.new.respond_to?` names the wrong set. What is lost is
  what the *instance* dispatches directly — every public method on a `Switches`,
  its own interface included: `set`, `required`, `optional`, `perform`,
  `settings`, `supplied_switches`, `to_h`, `unset_switches`. 52 names, not 17.
- **The question mark.** Stripping it would refuse working switches.
  `s.boolean(:tap)` reads back through `#tap?` and collides with nothing, so
  `--tap` has always been available as a flag. Of the 52 candidates, 52 are lost
  through `#set` and none through `#boolean`.
- **The list had gone stale.** `type` and `trust` are no longer methods and no
  longer at risk, while `default_is`, `default_to` and `defaults_to` are — this
  library patches them onto Object itself, and so manufactures three of its own
  collisions.

The check is `respond_to?(accessor)` on self, which is exact rather than
approximate: a name is lost precisely when it is dispatched directly, which is
precisely when `respond_to?` answers true. Checked against every lowercase name
on an instance, declared both ways, 124 cases, with no disagreement between what
is refused and what is actually lost.

A name OptionParser has is deliberately still allowed, 0.11.0 having given a
declared switch precedence over the parser.

### 0.13.0 (2026-08-17): the specs, from RSpec to Minitest

Minitest spec style is the convention everywhere else and `spec/all.rb` was the
laggard, having grown by about ninety lines of RSpec across 0.10.5 to 0.12.0
without the mismatch being raised. 75 examples converted, and the suite now runs
75 runs / 92 assertions — more assertions than examples because a raise with a
message pattern becomes two.

| RSpec | Minitest | count |
|---|---|---|
| `expect(x).to eq(y)` | `_(x).must_equal y` | 54 |
| `expect{...}.to raise_error(E)` | `_{...}.must_raise E` | 17 |
| `expect(x).to match(/../)` | `_(x).must_match(/../)` | 4 |
| `expect(x).to include(y)` | `_(x).must_include y` | 1 |
| `expect(x).to be_a(String)` | `_(x).must_be_kind_of String` | 1 |

`describe`/`it` and the `def build` helpers carried over untouched, and `let`
needed nothing, Minitest::Spec having its own. Outside the suite: the Rakefile's
`RSpec::Core::RakeTask` became `Rake::TestTask`, the gemspec's development
dependencies became minitest and rake, and the spec asserting those dependencies
was updated with them — it fails on its own conversion otherwise.

Four things the mechanical substitution got wrong, all worth knowing before the
next suite:

- `raise_error(E, /re/)` has no single Minitest equivalent. It becomes
  `error = _{...}.must_raise E` followed by `_(error.message).must_match(/re/)`,
  which is why the assertion count exceeds the example count.
- `eq(nil)` cannot become `must_equal nil` — Minitest 6 rejects it. It is
  `must_be_nil`.
- `must_equal {}` parses the hash literal as a block. A hash or array argument
  needs its parentheses kept: `must_equal({})`.
- A bare regex as the first argument — `must_match /re/` — is ambiguous with
  division and warns. Parenthesise it.

`not_to raise_error` has no equivalent either, there being no `refute_raises`.
The one instance asserts on the outcome instead: the call completes and returns a
Switches, which is what not raising means here.

No tool covers this hop. `should2expect` converts RSpec's `should ==` to
`expect`, which is RSpec to RSpec, and `minitest_test2spec` converts Minitest test
class style to spec style. RSpec to Minitest sits between the two and was done by
hand, scripted per pattern with the four exceptions above fixed afterwards.

Verified to have teeth rather than merely to pass: run against 0.11.0's library
the suite gives 5 errors, all in the collision describe, `SwitchNameCollision`
not existing there.

## Open questions

### respond_to_missing?

It ordinarily accompanies `#method_missing` and `Switches` does not define it.
Adding it is safe as of `NEVER_FORWARDED` and the refusal, both of which settle
which names the object owns, and it would answer true for the forwarded
OptionParser methods and for declared switches.

It would not have prevented 0.11.0's `#to_a` case, and would not guard the next
one. Ruby's conversion check falls back to calling `#method_missing` directly
when the ordinary dispatch fails, so `Array()` and the splat reach `#to_a`
whatever `respond_to?` answers. `NEVER_FORWARDED` is the guard; this is the
separate question of what the object admits to owning.

The awkwardness is that `respond_to?` would answer false for an undeclared name
while the call still returns nil through the settings OpenStruct. That is
OpenStruct's behaviour rather than this library's, but defining
`respond_to_missing?` makes it visible.

### Assignment through any of a switch's accessors

Allowing any one of a switch's OpenStruct methods to assign values for the
others, so as it is more than a read once switch and can be used for storage
throughout the application. Recorded in the header since before 0.9.0, with the
reservation that it might be stepping on Attributes.rb's toes.

## Settled earlier

- Clean up `#set`. Done as of 0.4.0.
- Use `!` for options with required switches. Done as of 0.6.0, changed to being
  for required arguments in 0.9.0.
- Reinstitute some specs. Done as of 0.9.8.
- Do away with optional arguments entirely, since it is obscure to specify a
  non-boolean switch and then supply no argument. Rejected: they serve as action
  oriented sub-commands.
