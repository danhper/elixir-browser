# elixir-browser

[![Build Status](https://travis-ci.org/tuvistavie/elixir-browser.svg?branch=master)](https://travis-ci.org/tuvistavie/elixir-browser)

Browser detection for Elixir.
This is a port from the [Ruby browser library](https://github.com/fnando/browser).

All the detection features have been ported, but not the meta and the language ones.

## Installation

Add `browser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:browser, "~> 0.1.0"}]
end
```

## Usage

```elixir
ua = "some string"
Browser.name(ua)            # readable browser name
Browser.version(ua)         # major version number
Browser.full_version(ua)
Browser.safari?(ua)
Browser.opera?(ua)
Browser.chrome?(ua)
Browser.chrome_os?(ua)
Browser.mobile?(ua)
Browser.tablet?(ua)
Browser.console?(ua)
Browser.firefox?(ua)
Browser.ie?(ua)
Browser.ie?(ua, 6)          # detect specific IE version
Browser.edge?(ua)           # Newest MS browser
Browser.modern?(ua)         # Webkit, Firefox 17+, IE 9+ and Opera 12+
Browser.platform(ua)        # return :mac, :windows, :linux or :other
Browser.ios?(ua)            # detect iOS
Browser.ios?(ua, 9)         # detect specific iOS version
Browser.mac?(ua)
Browser.windows?(ua)
Browser.windows_x64?(ua)
Browser.linux?(ua)
Browser.blackberry?(ua)
Browser.blackberry?(ua, 10) # detect specific BlackBerry version
Browser.bot?(ua)
Browser.search_engine?(ua)
Browser.phantom_js?(ua)
Browser.quicktime?(ua)
Browser.core_media?(ua)
Browser.silk?(ua)
Browser.android?(ua)
Browser.android?(ua, 4.2)   # detect Android Jelly Bean 4.2
Browser.known?(ua)          # has the browser been successfully detected?
```

See the [original Ruby library](https://github.com/fnando/browser) for more information.

### Elixir addition

You can also pass `Plug.Conn` instead of a string, the `user-agent` header will
be extracted and used.

```elixir
Browser.bot?(conn)
```
