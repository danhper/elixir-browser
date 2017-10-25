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
Browser.full_browser_name(ua) # Chrome 5.0.375.99
Browser.full_display(ua)    # example: Chrome 5.0.375.99 on MacOS 10.6.4 Snow Leopard
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
Browser.platform(ua)        # return :ios, :android, :mac, :windows, :linux or :other
Browser.full_platform_name(ua) # example: MacOS 10.6.4 Snow Leopard
Browser.device_type(ua)     # return :mobile, :tablet, :desktop, :console, :unknown
Browser.ios?(ua)            # detect iOS
Browser.ios?(ua, 9)         # detect specific iOS version
Browser.mac?(ua)
Browser.mac_version(ua)     # display version of Mac OSX. i.e. High Sierra
Browser.windows?(ua)
Browser.windows_x64?(ua)
Browser.windows_version_name # display version of Windows.  i.e. Windows 10
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

### Configuration

You can specify custom bots.txt file in your project's config.

```elixir
config :browser,
  bots_file: Path.join(File.cwd!, "bots.txt")  # bots.txt in project's root
```

Please note that option set as mobule attribute during compile time, so make sure you recompiled elixir-browser after changing this option or bots file itself.
