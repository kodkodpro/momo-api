# Phlex + RubyUI rules

This app builds HTML with **Phlex** (`phlex-rails`, `phlex-sorbet`) and uses
**RubyUI** (`ruby_ui`) as its design-system library. Read this file before
writing any view or component.

Docs:
- Phlex: https://www.phlex.fun/
- RubyUI: https://www.rubyui.com/

## Golden rules

1. **Prefer installing a RubyUI component over writing one yourself.**
   Use the generator (see "RubyUI CLI workflow" below) before hand-rolling.
2. **Every Phlex class is Sorbet-typed.** Start files with the standard
   `# typed: true` + `# frozen_string_literal: true` header.
3. **Inputs go through a `Props < T::Struct`** with `include Phlex::Sorbet`.
   Don't take loose keyword args on view/component classes.
4. **Don't bypass the base classes.** Pages inherit `Views::Base`, app
   components inherit `Components::Base`, design-system primitives inherit
   `RubyUI::Base`.
5. **Render RubyUI components as PascalCase method calls** (`Heading`, `Text`,
   `Card`) — the `RubyUI` module is included into `Components::Base`.

## Directory layout

```
app/
  views/                    # Page-level Phlex classes (Views::*)
    base.rb                 # Views::Base
    dashboard/index.rb      # Views::Dashboard::Index
  components/               # App-specific Phlex components (Components::*)
    base.rb                 # Components::Base
    layout.rb               # Components::Layout (Phlex::Rails::Layout)
    card.rb                 # Components::Card
    ruby_ui/                # Generated/customized RubyUI components
      base.rb               # RubyUI::Base (TailwindMerge)
      button/button.rb      # RubyUI::Button
      ...
```

- **Pages** (one per controller action) live in `app/views/`.
- **App-specific reusable components** live in `app/components/`.
- **Design-system primitives** live in `app/components/ruby_ui/` and are managed
  by the RubyUI generator. Edit these freely after install.

## Base classes (don't change unless you really mean to)

```ruby
# app/components/base.rb
class Components::Base < Phlex::HTML
  include RubyUI                              # makes Heading, Text, Card... available
  include Phlex::Rails::Helpers::Routes       # *_path / *_url helpers
end

# app/views/base.rb
class Views::Base < Components::Base
  include Chartkick::Helper
  def cache_store = Rails.cache
end

# app/components/ruby_ui/base.rb
class RubyUI::Base < Phlex::HTML
  # Merges default + user-provided attrs and dedupes Tailwind classes.
end
```

## File header

Every `.rb` file under `app/views` and `app/components` starts with:

```ruby
# typed: true
# frozen_string_literal: true
```

Use `# typed: strict` only for initializers / config, not for views/components.

## Anatomy of a page view

```ruby
# app/views/dashboard/index.rb
# typed: true
# frozen_string_literal: true

class Views::Dashboard::Index < Views::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :title, String
  end

  def view_template
    h1 { "Dashboard::Index #{title}" }
    p { "Find me in app/views/dashboard/index.rb" }
  end
end
```

Render from a controller:

```ruby
class Dashboard::HomeController < Dashboard::ApplicationController
  def index
    render Views::Dashboard::Index.new(title: "Home")
  end
end
```

## Anatomy of a component (with optional content + class merging)

```ruby
# app/components/card.rb
# typed: true
# frozen_string_literal: true

class Components::Card < Components::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :bordered, T::Boolean, default: false
    const :class_name, T.nilable(String)
  end

  def view_template
    div class: card_classes do
      div class: "p-4" do
        yield if block_given?
      end
    end
  end

  private

  def card_classes
    classes = ["rounded-lg bg-card text-card-foreground shadow-sm"]
    classes << "border" if bordered
    classes << class_name if class_name
    classes.join(" ")
  end
end
```

Notes:
- `include Phlex::Sorbet` turns each `Props` field into a typed reader (`title`,
  `bordered`, `class_name`).
- Use `yield if block_given?` for optional inner content; use `view_template(&)`
  + `div(&)` to forward a required block (see `Components::Layout`).
- Always type-check booleans with `T::Boolean` and nilables with
  `T.nilable(...)`. Provide `default:` where it makes sense.

## Composing RubyUI components

RubyUI components are called as PascalCase methods because `Components::Base`
includes the `RubyUI` module. Pass props as kwargs and content via block.

```ruby
# app/views/dashboard/analytics/analyze_event.rb (excerpt)
def view_template
  div class: "container p-4 sm:py-20 sm:px-0" do
    Heading level: 1 do
      analyzed_event.event_name.const_name.dasherize.titleize
    end

    Text class: "mt-1" do
      "From #{analyzed_event.start_date.to_human} to #{analyzed_event.end_date.to_human}"
    end

    Card class_name: "mt-4" do
      raw line_chart analyzed_event.grouped_counts
    end
  end
end
```

The `class:` you pass to a RubyUI component is run through `TailwindMerge` in
`RubyUI::Base`, so later/utility classes win over the component defaults — no
need to fight specificity by hand.

## Layout

`Components::Layout` is a Phlex layout (`include Phlex::Rails::Layout`). Don't
re-implement `<html>`/`<head>`/`<body>` in a view — render inside the layout.

```ruby
class Components::Layout < Components::Base
  include Phlex::Rails::Layout

  def view_template(&)
    doctype
    html do
      head { ... }
      body(class: "font-sans antialiased bg-background text-foreground", &)
    end
  end
end
```

## Tag DSL cheatsheet

- HTML tag = method (`div`, `span`, `h1`, `form`, `option`, `pre`, `code`, …).
- Attributes = kwargs: `a(href: path, class: "underline")`.
- Content = block: `div { "hi" }` or `div { Text { "hi" } }`.
- Boolean attributes: `option(value:, selected: true) { text }`.
- Use `raw "<svg>...</svg>".html_safe` only for trusted HTML (e.g. Chartkick).
- For data attributes use `data: { auto_submit: "" }`.

## RubyUI CLI workflow (do this first)

Available generators:

```bash
bin/rails generate ruby_ui:install            # one-time setup (already run)
bin/rails generate ruby_ui:install:docs       # optional docs
bin/rails generate ruby_ui:component:all      # list/install every component
bin/rails generate ruby_ui:component NAME     # install ONE component
```

Workflow whenever you need a UI primitive:

1. Check `app/components/ruby_ui/` — is it already installed?
2. If not, run the generator with `--pretend` first to see what files it would
   create:
   ```bash
   bin/rails generate ruby_ui:component Dialog --pretend
   ```
3. Run it for real:
   ```bash
   bin/rails generate ruby_ui:component Dialog
   ```
4. The generator writes files under `app/components/ruby_ui/<name>/`. Edit them
   to fit our conventions (file header, Sorbet, double quotes) and to tweak
   defaults — they're our code now.
5. Use the new component as `Dialog { ... }` from any view/component.

Only hand-write a brand-new component under `app/components/` (NOT `ruby_ui/`)
when there is no RubyUI equivalent. If unsure, ask before building from scratch.

## Anatomy of a RubyUI-style primitive

When you do need to write one (or are customizing a generated one), follow the
`RubyUI::Button` pattern: inherit `RubyUI::Base`, accept variant/size kwargs,
and expose the merged `attrs` to the tag.

```ruby
# app/components/ruby_ui/button/button.rb (excerpt)
module RubyUI
  class Button < Base
    def initialize(type: :button, variant: :primary, size: :md, icon: false, **attrs)
      @type = type
      @variant = variant.to_sym
      @size = size.to_sym
      @icon = icon
      super(**attrs)               # lets Base merge default_attrs with user attrs
    end

    def view_template(&)
      button(**attrs, &)           # attrs already has merged class + type
    end

    private

    def default_attrs
      { type: @type, class: default_classes }
    end
  end
end
```

Key points:
- Always call `super(**attrs)` so `RubyUI::Base` can merge user attrs and run
  `TailwindMerge` on `class:`.
- Override `default_attrs` (private) to declare baseline attributes/classes.
- Use `view_template(&)` and forward the block to the underlying tag so callers
  can pass content.

## Style (matches root `CLAUDE.md`)

- Double quotes for strings.
- Trailing commas on multiline arrays/hashes; multiline method args too.
- Hash shorthand: `option(value:, selected: true)` when the local matches.
- Compact class names: `class Views::Dashboard::Index < Views::Base`.
- No length limits on methods/classes/blocks — readability wins.

## Don'ts

- ❌ Don't put ERB templates in `app/views/` — this app is Phlex-only there.
- ❌ Don't take loose `**opts` on a Phlex class — define a `Props < T::Struct`.
- ❌ Don't mutate `attrs` from a RubyUI component's `view_template`; do it in
  `default_attrs` / `initialize` instead.
- ❌ Don't reimplement a primitive that exists in RubyUI — install it.
- ❌ Don't skip the Sorbet header or `include Phlex::Sorbet` on prop'd classes.
