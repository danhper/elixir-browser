defmodule BrowserTest do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn
  alias Browser.Ua

  test "returns empty string when Conn has no user-agent header" do
    assert conn(:get, "/") |> Ua.to_ua == ""
  end

  test "retrieves first UA when Conn has user-agent header" do
    conn = conn(:get, "/")
      |> put_req_header("user-agent", "Mozilla 5.0")
      |> put_req_header("user-agent", "Opera")

    assert conn |> Ua.to_ua == "Opera"
  end

  test "detects android" do
    ua = Fixtures.ua["ANDROID"]

    assert Browser.name(ua) == "Android"
    assert Browser.full_browser_name(ua) == "Android 3.1.2"
    assert Browser.full_display(ua) == "Android 3.1.2 on Android 1.5"
    assert Browser.android?(ua)
    refute Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.mobile?(ua)
    refute Browser.tablet?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "3.1.2"
    assert Browser.version(ua) == "3"
  end

  test "detects surface tablet" do
    ua = Fixtures.ua["SURFACE"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 10.0"
    assert Browser.full_display(ua) == "Internet Explorer 10.0 on Windows RT"
    assert Browser.surface?(ua)
    assert Browser.ie?(ua)
    refute Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "10.0"
    assert Browser.version(ua) == "10"
  end

  test "detects quicktime" do
    ua = Fixtures.ua["QUICKTIME"]

    assert Browser.name(ua) == "QuickTime"
    assert Browser.full_browser_name(ua) == "QuickTime 7.6.8"
    assert Browser.full_display(ua) == "QuickTime 7.6.8 on Windows XP"
    assert Browser.quicktime?(ua)
    assert Browser.full_version(ua) == "7.6.8"
    assert Browser.version(ua) == "7"
  end

  test "detects core media" do
    ua = Fixtures.ua["COREMEDIA"]

    assert Browser.name(ua) == "Apple CoreMedia"
    assert Browser.full_browser_name(ua) == "Apple CoreMedia 1.0.0.10F569"
    assert Browser.full_display(ua) == "Apple CoreMedia 1.0.0.10F569 on MacOS"
    assert Browser.core_media?(ua)
    assert Browser.full_version(ua) == "1.0.0.10F569"
    assert Browser.version(ua) == "1"
  end

  test "detects phantom.js" do
    ua = Fixtures.ua["PHANTOM_JS"]

    assert Browser.name(ua) == "PhantomJS"
    assert Browser.full_browser_name(ua) == "PhantomJS 1.9.0"
    assert Browser.full_display(ua) == "PhantomJS 1.9.0 on MacOS"
    assert Browser.phantom_js?(ua)
    refute Browser.tablet?(ua)
    refute Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "1.9.0"
    assert Browser.version(ua) == "1"
  end

  test "detects other mobiles" do
    ua = "Symbian OS"
    assert Browser.mobile?(ua)
    refute Browser.tablet?(ua)

    ua = "MIDP-2.0"
    assert Browser.mobile?(ua)
    refute Browser.tablet?(ua)
  end

  test "detects windows mobile" do
    ua = Fixtures.ua["WINDOWS_MOBILE"]

    assert Browser.mobile?(ua)
    assert Browser.windows?(ua)
    assert Browser.windows_mobile?(ua)
    refute Browser.windows_phone?(ua)
    refute Browser.tablet?(ua)
  end

  test "detects unknown id" do
    ua = "Unknown"
    assert Browser.id(ua) == :other
  end

  test "detects unknown name" do
    ua = "Unknown"
    assert Browser.name(ua) == "Other"
    assert Browser.full_browser_name(ua) == "Other 0.0"
    assert Browser.full_display(ua) == "Other 0.0 on Other"
  end

  test "detects ios platform" do
    iphone = Fixtures.ua["IPHONE"]
    ipad = Fixtures.ua["IPAD"]

    assert Browser.platform(iphone)  == :ios
    assert Browser.platform(ipad)  == :ios
  end

  test "detects android platform" do
    android_1 = Fixtures.ua["ANDROID"]
    android_2 = Fixtures.ua["ANDROID_WITH_SAFARI"]

    assert Browser.platform(android_1)  == :android
    assert Browser.platform(android_2)  == :android
  end

  test "detects mac platform" do
    ua = "Mac OS X"
    assert Browser.platform(ua)  == :mac
    assert Browser.mac?(ua)
  end

  test "detects mac version with underscore notation" do
    ua = "Intel Mac OS X 10_13_1; en-us"
    assert Browser.mac_version(ua) == "10.13.1"
  end

  test "detects mac version with dot notation" do
    ua = "Intel Mac OS X 10.13.1; en-us"
    assert Browser.mac_version(ua) == "10.13.1"
  end

  test "mac version name" do
    ua_10_0 = "Intel Mac OS X 10_0_1; en-us"
    ua_10_1 = "Intel Mac OS X 10_1_1; en-us"
    ua_10_2 = "Intel Mac OS X 10_2_1; en-us"
    ua_10_3 = "Intel Mac OS X 10_3_1; en-us"
    ua_10_4 = "Intel Mac OS X 10_4_1; en-us"
    ua_10_5 = "Intel Mac OS X 10_5_1; en-us"
    ua_10_6 = "Intel Mac OS X 10_6_1; en-us"
    ua_10_7 = "Intel Mac OS X 10_7_1; en-us"
    ua_10_8 = "Intel Mac OS X 10_8_1; en-us"
    ua_10_9 = "Intel Mac OS X 10_9_1; en-us"
    ua_10_10 = "Intel Mac OS X 10_10_1; en-us"
    ua_10_11 = "Intel Mac OS X 10_11_1; en-us"
    ua_10_12 = "Intel Mac OS X 10_12_1; en-us"
    ua_10_13 = "Intel Mac OS X 10_13_1; en-us"

    assert Browser.mac_version_name(ua_10_13) == "High Sierra"
    assert Browser.mac_version_name(ua_10_12) == "Sierra"
    assert Browser.mac_version_name(ua_10_11) == "El Capitan"
    assert Browser.mac_version_name(ua_10_10) == "Yosemite"
    assert Browser.mac_version_name(ua_10_9) == "Mavericks"
    assert Browser.mac_version_name(ua_10_8) == "Mountain Lion"
    assert Browser.mac_version_name(ua_10_7) == "Lion"
    assert Browser.mac_version_name(ua_10_6) == "Snow Leopard"
    assert Browser.mac_version_name(ua_10_5) == "Leopard"
    assert Browser.mac_version_name(ua_10_4) == "Tiger"
    assert Browser.mac_version_name(ua_10_3) == "Panther"
    assert Browser.mac_version_name(ua_10_2) == "Jaguar"
    assert Browser.mac_version_name(ua_10_1) == "Puma"
    assert Browser.mac_version_name(ua_10_0) == "Cheetah"
    assert Browser.mac_version_name("Mac OS X") == ""
  end

  test "detects linux platform" do
    ua = "Linux"
    assert Browser.platform(ua)  == :linux
    assert Browser.linux?(ua)
  end

  test "detects unknown platform" do
    ua = "Unknown"
    assert Browser.platform(ua)  == :other
  end

  test "detects mobile device type" do
    ua = Fixtures.ua["IPHONE"]
    assert Browser.device_type(ua) == :mobile
  end

  test "detects tablet device type" do
    ua = Fixtures.ua["IPAD"]
    assert Browser.device_type(ua) == :tablet
  end

  test "detects console device type" do
    ua = Fixtures.ua["XBOXONE"]
    assert Browser.device_type(ua) == :console
  end

  test "detects desktop device type" do
    ua = Fixtures.ua["CHROME"]
    assert Browser.device_type(ua) == :desktop
  end

  test "detects unknown device type" do
    ua = "Unknown"
    assert Browser.device_type(ua)  == :unknown
  end

  test "detects xoom" do
    ua = Fixtures.ua["XOOM"]

    assert Browser.android?(ua)
    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects nexus tablet" do
    ua = Fixtures.ua["NEXUS_TABLET"]

    assert Browser.android?(ua)
    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects nook" do
    ua = Fixtures.ua["NOOK"]

    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects samsung" do
    ua = Fixtures.ua["SAMSUNG"]

    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects tv" do
    ua = Fixtures.ua["SMART_TV"]
    assert Browser.tv?(ua)
  end

  test "knows a supported browser" do
    ua = "Chrome"
    assert Browser.known?(ua)
  end

  test "does not know an unsupported browser" do
    ua = "Fancy new browser"
    refute Browser.known?(ua)
  end

  test "detects adobe air" do
    ua = Fixtures.ua["ADOBE_AIR"]

    assert Browser.adobe_air?(ua)
    assert Browser.webkit?(ua)
    assert Browser.version(ua) == "13"
    assert Browser.full_version(ua) == "13.0"
    assert Browser.name(ua) == "Other"
    assert Browser.full_browser_name(ua) == "Other 13.0"
    assert Browser.full_display(ua) == "Other 13.0 on MacOS"
  end

  # android

  test "detect android cupcake (1.5)" do
    ua = Fixtures.ua["ANDROID_CUPCAKE"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 1.5)
  end

  test "detect android donut (1.6)" do
    ua = Fixtures.ua["ANDROID_DONUT"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 1.6)
  end

  test "detect android eclair (2.1)" do
    ua = Fixtures.ua["ANDROID_ECLAIR_21"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 2.1)
  end

  test "detect android froyo (2.2)" do
    ua = Fixtures.ua["ANDROID_FROYO"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 2.2)
  end

  test "detect android gingerbread (2.3)" do
    ua = Fixtures.ua["ANDROID_GINGERBREAD"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 2.3)
  end

  test "detect android honeycomb (3.0)" do
    ua = Fixtures.ua["ANDROID_HONEYCOMB_30"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 3.0)
  end

  test "detect android ice cream sandwich (4.0)" do
    ua = Fixtures.ua["ANDROID_ICECREAM"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 4.0)
  end

  test "detect android jellybean (4.1)" do
    ua = Fixtures.ua["ANDROID_JELLYBEAN_41"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 4.1)
  end

  test "detect android jellybean (4.2)" do
    ua = Fixtures.ua["ANDROID_JELLYBEAN_42"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 4.2)
  end

  test "detect android jellybean (4.3)" do
    ua = Fixtures.ua["ANDROID_JELLYBEAN_43"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 4.3)
  end

  test "detect android kitkat (4.4)" do
    ua = Fixtures.ua["ANDROID_KITKAT"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 4.4)
  end

  test "detect android lollipop (5.0)" do
    ua = Fixtures.ua["ANDROID_LOLLIPOP_50"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 5.0)
  end

  test "detect android lollipop (5.1)" do
    ua = Fixtures.ua["ANDROID_LOLLIPOP_51"]
    assert Browser.android?(ua)
    assert Browser.android?(ua, 5.1)
  end

  test "detect android tv" do
    ua = Fixtures.ua["ANDROID_TV"]
    assert Browser.android?(ua)
    assert Browser.tv?(ua)
  end

  test "detect nexus player" do
    ua = Fixtures.ua["ANDROID_NEXUS_PLAYER"]
    assert Browser.android?(ua)
    assert Browser.tv?(ua)
  end

  # blackberry

  test "detects blackberry" do
    ua = Fixtures.ua["BLACKBERRY"]

    assert Browser.name(ua), "BlackBerry"
    assert Browser.full_browser_name(ua) == "BlackBerry 4.1.0"
    assert Browser.full_display(ua) == "BlackBerry 4.1.0 on BlackBerry"
    assert Browser.blackberry?(ua)
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "4.1.0"
    assert Browser.version(ua) == "4"
  end

  test "detects blackberry4" do
    ua = Fixtures.ua["BLACKBERRY4"]

    assert Browser.name(ua), "BlackBerry"
    assert Browser.full_browser_name(ua) == "BlackBerry 4.2.1"
    assert Browser.full_display(ua) == "BlackBerry 4.2.1 on BlackBerry 4"
    assert Browser.blackberry_version(ua) == "4"
    assert Browser.blackberry?(ua, 4)
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "4.2.1"
    assert Browser.version(ua) == "4"
  end

  test "detects blackberry5" do
    ua = Fixtures.ua["BLACKBERRY5"]

    assert Browser.name(ua), "BlackBerry"
    assert Browser.full_browser_name(ua) == "BlackBerry 5.0.0.93"
    assert Browser.full_display(ua) == "BlackBerry 5.0.0.93 on BlackBerry 5"
    assert Browser.blackberry?(ua, 5)
    assert Browser.blackberry_version(ua) == "5"
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "5.0.0.93"
    assert Browser.version(ua) == "5"
  end

  test "detects blackberry6" do
    ua = Fixtures.ua["BLACKBERRY6"]

    assert Browser.name(ua) =="Safari"
    assert Browser.full_browser_name(ua) == "Safari 534.11"
    assert Browser.full_display(ua) == "Safari 534.11 on BlackBerry 6"
    assert Browser.blackberry?(ua, 6)
    assert Browser.blackberry_version(ua) == "6"
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "534.11"
    assert Browser.version(ua) == "534"
  end

  test "detects blackberry7" do
    ua = Fixtures.ua["BLACKBERRY7"]

    assert Browser.name(ua) =="Safari"
    assert Browser.full_browser_name(ua) == "Safari 534.11"
    assert Browser.full_display(ua) == "Safari 534.11 on BlackBerry 7"
    assert Browser.blackberry?(ua, 7)
    assert Browser.blackberry_version(ua) == "7"
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "534.11"
    assert Browser.version(ua) == "534"
  end

  test "detects blackberry10" do
    ua = Fixtures.ua["BLACKBERRY10"]

    assert Browser.name(ua) =="Safari"
    assert Browser.full_browser_name(ua) == "Safari 10.0.9.1675"
    assert Browser.full_display(ua) == "Safari 10.0.9.1675 on BlackBerry 10"
    assert Browser.blackberry_version(ua) =="10"
    assert Browser.blackberry?(ua, 10)
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "10.0.9.1675"
    assert Browser.version(ua) == "10"
  end

  test "detects blackberry playbook tablet" do
    ua = Fixtures.ua["PLAYBOOK"]

    refute Browser.android?(ua)
    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)

    assert Browser.full_version(ua) == "7.2.1.0"
    assert Browser.version(ua) == "7"
  end


  # bots
  test "detects bots" do
    refute Browser.bot?("")
    refute Browser.bot?(%Plug.Conn{})

    for {_key, ua} <- Fixtures.bot_ua do
      assert Browser.bot?(ua), "#{ua} should be a bot"

      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_req_header("user-agent", ua)
      assert Browser.bot?(conn), "#{ua} should be a bot"
    end

    ua = Fixtures.ua["CHROME"]
    refute Browser.bot?(ua)
  end

  test "detects bots based on keywords" do
    test_cases = ~w(
      content-fetcher
      content-crawler
      some-search-engine
      monitoring-service
      content-spider
      some-bot
    )

    for ua <- test_cases do
      assert Browser.bot?(ua), "#{ua} should be a bot"

      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_req_header("user-agent", ua)
      assert Browser.bot?(conn), "#{ua} should be a bot"
    end
  end

  test "respects bot_exceptions" do
    test_cases = [
      "ruby build",
      "pinterest/android",
      "pinterest/ios",
      "yandexsearchbrowser"
    ]

    for ua <- test_cases do
      refute Browser.bot?(ua), "#{ua} should not be a bot"
    end
  end

  test "detects Google Page Speed as a bot" do
    ua = Fixtures.ua["GOOGLE_PAGE_SPEED_INSIGHTS"]
    assert Browser.bot?(ua)
  end

  test "doesn't consider empty UA as bot" do
    ua = ""
    refute Browser.bot?(ua)
  end

  test "allows setting empty string as bots" do
    ua = ""

    assert Browser.bot?(ua, detect_empty_ua: true)
  end

  test "doesn't detect mozilla as a bot when considering empty UA" do
    ua = "Mozilla"

    refute Browser.bot?(ua, detect_empty_ua: true)
  end

  test "returns bot name" do
    ua = Fixtures.ua["GOOGLE_BOT"]
    assert Browser.bot_name(ua) == "googlebot"

    ua = Fixtures.ua["FACEBOOK_BOT"]
    assert Browser.bot_name(ua) == "facebookexternalhit"
  end

  test "returns bot name (empty string ua detection enabled)" do
    ua = ""

    assert Browser.bot_name(ua, detect_empty_ua: true) == "Generic Bot"
  end

  test "returns nil for non-bots" do
    ua = Fixtures.ua["CHROME"]
    assert Browser.bot_name(ua) == nil
  end

  test "detects as search engines" do
    refute Browser.search_engine?("")
    refute Browser.search_engine?(%Plug.Conn{})

    Enum.each ~w[
      ASK
      BAIDU
      BINGBOT
      DUCKDUCKGO
      GOOGLE_BOT
      YAHOO_SLURP
    ], fn key ->
      ua = Fixtures.ua[key]
      assert Browser.search_engine?(ua), "#{Fixtures.ua[key]} should be a search engine"

      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_req_header("user-agent", ua)
      assert Browser.search_engine?(conn), "#{Fixtures.ua[key]} should be a search engine"
    end
  end

  test "detects Google Structured Data Testing Tool as a bot" do
    ua = Fixtures.ua["GOOGLE_STRUCTURED_DATA_TESTING_TOOL"]

    assert Browser.bot?(ua), "Google Structured Data Testing Tool should be a bot"
  end

  test "detects Daumoa" do
    ua = Fixtures.ua["DAUMOA"]

    assert :ie == Browser.id(ua)
    assert "Internet Explorer" == Browser.name(ua)
    assert "0.0" == Browser.msie_full_version(ua)
    assert "0" == Browser.msie_version(ua)
    assert "0.0" == Browser.full_version(ua)
    assert "0" == Browser.version(ua)
    assert Browser.ie?(ua)
    assert Browser.bot?(ua)
    refute Browser.windows10?(ua)
    refute Browser.windows_phone?(ua)
    refute Browser.edge?(ua)
    refute Browser.modern?(ua)
    refute Browser.mobile?(ua)
    refute Browser.webkit?(ua)
    refute Browser.chrome?(ua)
    refute Browser.safari?(ua)
  end

  # chrome

  test "detects chrome" do
    ua = Fixtures.ua["CHROME"]

    assert Browser.name(ua) =="Chrome"
    assert Browser.full_browser_name(ua) == "Chrome 5.0.375.99"
    assert Browser.full_display(ua) == "Chrome 5.0.375.99 on MacOS 10.6.4 Snow Leopard"
    assert Browser.chrome?(ua)
    refute Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "5.0.375.99"
    assert Browser.version(ua) == "5"
  end

  test "detects mobile chrome" do
    ua = Fixtures.ua["MOBILE_CHROME"]

    assert Browser.name(ua) =="Chrome"
    assert Browser.full_browser_name(ua) == "Chrome 19.0.1084.60"
    assert Browser.full_display(ua) == "Chrome 19.0.1084.60 on iOS 5"
    assert Browser.chrome?(ua)
    refute Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "19.0.1084.60"
    assert Browser.version(ua) == "19"
  end

  test "detects samsung chrome" do
    ua = Fixtures.ua["SAMSUNG_CHROME"]

    assert Browser.name(ua) =="Chrome"
    assert Browser.full_browser_name(ua) == "Chrome 28.0.1500.94"
    assert Browser.full_display(ua) == "Chrome 28.0.1500.94 on Android 4.4.2"
    assert Browser.chrome?(ua)
    assert Browser.android?(ua)
    refute Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "28.0.1500.94"
    assert Browser.version(ua) == "28"
  end

  test "detects chrome os" do
    ua = Fixtures.ua["CHROME_OS"]
    assert Browser.chrome_os?(ua)
  end

  test "detects yandex browser" do
    ua = Fixtures.ua["YANDEX_BROWSER"]

    assert Browser.yandex?(ua)
    assert Browser.chrome?(ua)
    refute Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.full_version(ua) == "41.0.2272.118"
    assert Browser.version(ua) == "41"
  end

  # console
  test "detects nintendo wii" do
    ua = Fixtures.ua["NINTENDO_WII"]

    assert Browser.console?(ua)
    assert Browser.nintendo?(ua)
  end

  test "detects nintendo wii u" do
    ua = Fixtures.ua["NINTENDO_WIIU"]

    assert Browser.console?(ua)
    assert Browser.nintendo?(ua)
  end

  test "detects playstation 3" do
    ua = Fixtures.ua["PLAYSTATION3"]

    assert Browser.console?(ua)
    assert Browser.playstation?(ua)
    refute Browser.playstation4?(ua)
  end

  test "detects playstation 4" do
    ua = Fixtures.ua["PLAYSTATION4"]

    assert Browser.console?(ua)
    assert Browser.playstation?(ua)
    assert Browser.playstation4?(ua)
  end

  test "detects xbox 360" do
    ua = Fixtures.ua["XBOX360"]

    assert Browser.console?(ua)
    assert Browser.xbox?(ua)
    refute Browser.xbox_one?(ua)
  end

  test "detects xbox one" do
    ua = Fixtures.ua["XBOXONE"]

    assert Browser.console?(ua)
    assert Browser.xbox?(ua)
    assert Browser.xbox_one?(ua)
  end

  test "detects psp" do
    ua = Fixtures.ua["PSP"]

    assert Browser.name(ua) == "PlayStation Portable"
    assert Browser.full_browser_name(ua) == "PlayStation Portable 0.0"
    assert Browser.full_display(ua) == "PlayStation Portable 0.0 on Other"
    assert Browser.psp?(ua)
    refute Browser.psp_vita?(ua)
    assert Browser.mobile?(ua)
  end

  test "detects psp vita" do
    ua = Fixtures.ua["PSP_VITA"]

    assert Browser.name(ua) == "PlayStation Portable"
    assert Browser.full_display(ua) == "PlayStation Portable 0.0 on Other"
    assert Browser.psp?(ua)
    assert Browser.psp_vita?(ua)
    assert Browser.mobile?(ua)
  end

  # firefox

  test "detects firefox" do
    ua = Fixtures.ua["FIREFOX"]

    assert Browser.name(ua) == "Firefox"
    assert Browser.full_browser_name(ua) == "Firefox 3.8"
    assert Browser.full_display(ua) == "Firefox 3.8 on Linux"
    assert Browser.firefox?(ua)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "3.8"
    assert Browser.version(ua) == "3"
  end

  test "detects modern firefox" do
    ua = Fixtures.ua["FIREFOX_MODERN"]

    assert Browser.id(ua) == :firefox
    assert Browser.name(ua) == "Firefox"
    assert Browser.full_browser_name(ua) == "Firefox 17.0"
    assert Browser.full_display(ua) == "Firefox 17.0 on Linux"
    assert Browser.firefox?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "17.0"
    assert Browser.version(ua) == "17"
  end

  test "detects firefox android tablet" do
    ua = Fixtures.ua["FIREFOX_TABLET"]

    assert Browser.id(ua) == :firefox
    assert Browser.name(ua) == "Firefox"
    assert Browser.full_browser_name(ua) == "Firefox 14.0"
    assert Browser.full_display(ua) == "Firefox 14.0 on Android"
    assert Browser.firefox?(ua)
    assert Browser.modern?(ua)
    assert Browser.tablet?(ua)
    assert Browser.android?(ua)
    assert Browser.full_version(ua) == "14.0"
    assert Browser.version(ua) == "14"
  end

  # IE

  test "detects ie6" do
    ua = Fixtures.ua["IE6"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 6.0"
    assert Browser.full_display(ua) == "Internet Explorer 6.0 on Windows XP"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 6)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "6.0"
    assert Browser.version(ua) == "6"
  end

  test "detects ie7" do
    ua = Fixtures.ua["IE7"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 7.0"
    assert Browser.full_display(ua) == "Internet Explorer 7.0 on Windows Vista"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 7)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "7.0"
    assert Browser.version(ua) == "7"
  end

  test "detects ie8" do
    ua = Fixtures.ua["IE8"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 8.0"
    assert Browser.full_display(ua) == "Internet Explorer 8.0 on Windows 8"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 8)
    refute Browser.modern?(ua)
    refute Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "8.0"
    assert Browser.version(ua) == "8"
  end

  test "detects ie8 in compatibility view" do
    ua = Fixtures.ua["IE8_COMPAT"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 8.0"
    assert Browser.full_display(ua) == "Internet Explorer 8.0 on Windows Vista"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 8)
    refute Browser.modern?(ua)
    assert Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "8.0"
    assert Browser.version(ua) == "8"
    assert Browser.msie_full_version(ua) == "7.0"
    assert Browser.msie_version(ua) == "7"
  end

  test "detects ie9" do
    ua = Fixtures.ua["IE9"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 9.0"
    assert Browser.full_display(ua) == "Internet Explorer 9.0 on Windows 7"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 9)
    assert Browser.modern?(ua)
    refute Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "9.0"
    assert Browser.version(ua) == "9"
  end

  test "detects ie9 in compatibility view" do
    ua = Fixtures.ua["IE9_COMPAT"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 9.0"
    assert Browser.full_display(ua) == "Internet Explorer 9.0 on Windows Vista"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 9)
    refute Browser.modern?(ua)
    assert Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "9.0"
    assert Browser.version(ua) == "9"
    assert Browser.msie_full_version(ua) == "7.0"
    assert Browser.msie_version(ua) == "7"
  end

  test "detects ie10" do
    ua = Fixtures.ua["IE10"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 10.0"
    assert Browser.full_display(ua) == "Internet Explorer 10.0 on Windows 7"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 10)
    assert Browser.modern?(ua)
    refute Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "10.0"
    assert Browser.version(ua) == "10"
  end

  test "detects ie10 in compatibility view" do
    ua = Fixtures.ua["IE10_COMPAT"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 10.0"
    assert Browser.full_display(ua) == "Internet Explorer 10.0 on Windows 7"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 10)
    refute Browser.modern?(ua)
    assert Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "10.0"
    assert Browser.version(ua) == "10"
    assert Browser.msie_full_version(ua) == "7.0"
    assert Browser.msie_version(ua) == "7"
  end

  test "detects ie11" do
    ua = Fixtures.ua["IE11"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 11.0"
    assert Browser.full_display(ua) == "Internet Explorer 11.0 on Windows 7"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 11)
    assert Browser.modern?(ua)
    refute Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "11.0"
    assert Browser.version(ua) == "11"
  end

  test "detects ie11 in compatibility view" do
    ua = Fixtures.ua["IE11_COMPAT"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 11.0"
    assert Browser.full_display(ua) == "Internet Explorer 11.0 on Windows 8.1"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 11)
    refute Browser.modern?(ua)
    assert Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "11.0"
    assert Browser.version(ua) == "11"
    assert Browser.msie_full_version(ua) == "7.0"
    assert Browser.msie_version(ua) == "7"
  end

  test "detects Lumia 800" do
    ua = Fixtures.ua["LUMIA800"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 9.0"
    assert Browser.full_display(ua) == "Internet Explorer 9.0 on Windows 7"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 9)
    assert Browser.full_version(ua) == "9.0"
    assert Browser.version(ua) == "9"
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
  end

  test "detects ie11 touch desktop pc" do
    ua = Fixtures.ua["IE11_TOUCH_SCREEN"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 11.0"
    assert Browser.full_display(ua) == "Internet Explorer 11.0 on Windows 8.1"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 11)
    assert Browser.modern?(ua)
    refute Browser.compatibility_view?(ua)
    refute Browser.windows_rt?(ua)
    assert Browser.windows_touchscreen_desktop?(ua)
    assert Browser.windows8?(ua)
    assert Browser.full_version(ua) == "11.0"
    assert Browser.version(ua) == "11"
  end

  test "detects Microsoft Edge" do
    ua = Fixtures.ua["MS_EDGE"]

    assert Browser.id(ua) == :edge
    assert Browser.name(ua) == "Microsoft Edge"
    assert Browser.full_browser_name(ua) == "Microsoft Edge 12.0"
    assert Browser.full_display(ua) == "Microsoft Edge 12.0 on Windows 10"
    assert Browser.full_version(ua) == "12.0"
    assert Browser.version(ua) == "12"
    assert Browser.windows10?(ua)
    assert Browser.edge?(ua)
    assert Browser.modern?(ua)
    refute Browser.webkit?(ua)
    refute Browser.chrome?(ua)
    refute Browser.safari?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects Microsoft Edge in compatibility view" do
    ua = Fixtures.ua["MS_EDGE_COMPAT"]

    assert Browser.id(ua) == :edge
    assert Browser.name(ua) == "Microsoft Edge"
    assert Browser.full_browser_name(ua) == "Microsoft Edge 12.0"
    assert Browser.full_display(ua) == "Microsoft Edge 12.0 on Windows 8"
    assert Browser.full_version(ua) == "12.0"
    assert Browser.version(ua) == "12"
    assert Browser.msie_full_version(ua) == "7.0"
    assert Browser.msie_version(ua) == "7"
    assert Browser.edge?(ua)
    assert Browser.compatibility_view?(ua)
    refute Browser.modern?(ua)
    refute Browser.webkit?(ua)
    refute Browser.chrome?(ua)
    refute Browser.safari?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects Microsoft Edge Mobile" do
    ua = Fixtures.ua["MS_EDGE_MOBILE"]

    assert Browser.id(ua) == :edge
    assert Browser.name(ua) == "Microsoft Edge"
    assert Browser.full_browser_name(ua) == "Microsoft Edge 12.0"
    assert Browser.full_display(ua) == "Microsoft Edge 12.0 on Android 4.2.1"
    assert Browser.full_version(ua) == "12.0"
    assert Browser.version(ua) == "12"
    refute Browser.windows10?(ua)
    assert Browser.windows_phone?(ua)
    assert Browser.edge?(ua)
    assert Browser.modern?(ua)
    assert Browser.mobile?(ua)
    refute Browser.webkit?(ua)
    refute Browser.chrome?(ua)
    refute Browser.safari?(ua)
  end

  test "detects ie8 without Trident" do
    ua = Fixtures.ua["IE8_WITHOUT_TRIDENT"]

    assert Browser.id(ua) == :ie
    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 8.0"
    assert Browser.full_display(ua) == "Internet Explorer 8.0 on Windows Vista"
    assert Browser.msie_full_version(ua) == "8.0"
    assert Browser.msie_version(ua) == "8"
    assert Browser.full_version(ua) == "8.0"
    assert Browser.version(ua) == "8"
    refute Browser.windows10?(ua)
    refute Browser.windows_phone?(ua)
    refute Browser.edge?(ua)
    refute Browser.modern_edge?(ua)
    refute Browser.modern?(ua)
    refute Browser.modern_ie_version?(ua)
    refute Browser.mobile?(ua)
    refute Browser.webkit?(ua)
    refute Browser.chrome?(ua)
    refute Browser.safari?(ua)
  end

  test "detects ie9 without Trident" do
    ua = Fixtures.ua["IE9_WITHOUT_TRIDENT"]

    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 9.0"
    assert Browser.full_display(ua) == "Internet Explorer 9.0 on Windows 7"
    assert Browser.ie?(ua)
    assert Browser.ie?(ua, 9)
    assert Browser.modern?(ua)
    refute Browser.compatibility_view?(ua)
    assert Browser.full_version(ua) == "9.0"
    assert Browser.version(ua) == "9"
    refute Browser.modern_edge?(ua)
    assert Browser.modern_ie_version?(ua)
  end

  test "detects windows phone" do
    ua = Fixtures.ua["WINDOWS_PHONE"]

    assert Browser.ie?(ua)
    assert Browser.version(ua) == "7"
    assert Browser.mobile?(ua)
    assert Browser.windows_phone?(ua)
    refute Browser.windows_mobile?(ua)
    refute Browser.tablet?(ua)
  end

  test "detects windows phone 8" do
    ua = Fixtures.ua["WINDOWS_PHONE8"]

    assert Browser.ie?(ua)
    assert Browser.version(ua) == "10"
    assert Browser.mobile?(ua)
    assert Browser.windows_phone?(ua)
    refute Browser.windows_mobile?(ua)
    refute Browser.tablet?(ua)
  end

  test "detects windows phone 8.1" do
    ua = Fixtures.ua["WINDOWS_PHONE_81"]

    assert Browser.ie?(ua)
    assert Browser.name(ua) == "Internet Explorer"
    assert Browser.full_browser_name(ua) == "Internet Explorer 11.0"
    assert Browser.full_display(ua) == "Internet Explorer 11.0 on iOS 7"
    assert Browser.id(ua) == :ie
    assert Browser.version(ua) == "11"
    assert Browser.full_version(ua) == "11.0"
    assert Browser.mobile?(ua)
    assert Browser.windows_phone?(ua)
    refute Browser.windows_mobile?(ua)
    refute Browser.tablet?(ua)
  end

  test "detects windows mobile (windows phone 8)" do
    ua = Fixtures.ua["WINDOWS_PHONE8"]

    assert Browser.ie?(ua)
    assert Browser.version(ua) == "10"
    assert Browser.mobile?(ua)
    assert Browser.windows_phone?(ua)
    refute Browser.windows_mobile?(ua)
    refute Browser.tablet?(ua)
  end

  test "detects windows x64" do
    ua = Fixtures.ua["IE10_X64_WINX64"]
    assert Browser.windows_x64?(ua)
    refute Browser.windows_wow64?(ua)
    assert Browser.windows_x64_inclusive?(ua)
  end

  test "detects windows wow64" do
    ua = Fixtures.ua["WINDOWS_WOW64"]
    refute Browser.windows_x64?(ua)
    assert Browser.windows_wow64?(ua)
    assert Browser.windows_x64_inclusive?(ua)
  end

  test "detects windows platform" do
    ua = "Windows"
    assert Browser.platform(ua) == :windows
    assert Browser.windows?(ua)
  end

  test "detects windows_xp" do
    ua = Fixtures.ua["WINDOWS_XP"]

    assert Browser.windows?(ua)
    assert Browser.windows_xp?(ua)
  end

  test "detects windows_vista" do
    ua = Fixtures.ua["WINDOWS_VISTA"]

    assert Browser.windows?(ua)
    assert Browser.windows_vista?(ua)
  end

  test "detects windows7" do
    ua = Fixtures.ua["WINDOWS7"]

    assert Browser.windows?(ua)
    assert Browser.windows7?(ua)
  end

  test "detects windows8" do
    ua = Fixtures.ua["WINDOWS8"]

    assert Browser.windows?(ua)
    assert Browser.windows8?(ua)
    refute Browser.windows8_1?(ua)
  end

  test "detects windows8.1" do
    ua = Fixtures.ua["WINDOWS81"]

    assert Browser.windows?(ua)
    assert Browser.windows8?(ua)
    assert Browser.windows8_1?(ua)
  end

  test "don't detect as two ie different versions" do
    ua = Fixtures.ua["IE8"]
    assert Browser.ie?(ua, 8)
    refute Browser.ie?(ua, 7)
  end

  test "detects windows version" do
    phone = Fixtures.ua["WINDOWS_PHONE"]
    phone8 = Fixtures.ua["WINDOWS_PHONE8"]
    phone81 = Fixtures.ua["WINDOWS_PHONE_81"]
    none = "Windows"
    xp = Fixtures.ua["WINDOWS_XP"]
    vista = Fixtures.ua["WINDOWS_VISTA"]
    win7 = Fixtures.ua["WINDOWS7"]
    win8 = Fixtures.ua["WINDOWS8"]
    win81 = Fixtures.ua["WINDOWS81"]
    win10 = Fixtures.ua["MS_EDGE"]

    assert Browser.windows_version_name(phone) == "Phone"
    assert Browser.windows_version_name(phone8) == "Phone"
    assert Browser.windows_version_name(phone81) == "Phone"
    assert Browser.windows_version_name(none) == ""
    assert Browser.windows_version_name(xp) == "XP"
    assert Browser.windows_version_name(vista) == "Vista"
    assert Browser.windows_version_name(win7) == "7"
    assert Browser.windows_version_name(win8) == "8"
    assert Browser.windows_version_name(win81) == "8.1"
    assert Browser.windows_version_name(win10) == "10"
  end

  # ios

   test "detects iphone" do
    ua = Fixtures.ua["IPHONE"]

    assert Browser.name(ua) == "iPhone"
    assert Browser.full_browser_name(ua) == "iPhone 3.0"
    assert Browser.full_display(ua) == "iPhone 3.0 on iOS 3"
    assert Browser.iphone?(ua)
    assert Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.ios?(ua)
    refute Browser.tablet?(ua)
    refute Browser.mac?(ua)
    assert Browser.full_version(ua) == "3.0"
    assert Browser.version(ua) == "3"
  end

  test "detects safari" do
    ua = Fixtures.ua["SAFARI"]

    assert Browser.name(ua) == "Safari"
    assert Browser.full_browser_name(ua) == "Safari 5.0.1"
    assert Browser.full_display(ua) == "Safari 5.0.1 on MacOS 10.6.4 Snow Leopard"
    assert Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.full_version(ua) == "5.0.1"
    assert Browser.version(ua) == "5"
  end

  test "detects safari in webapp mode" do
    ua = Fixtures.ua["SAFARI_IPAD_WEBAPP_MODE"]
    assert Browser.safari?(ua)

    ua = Fixtures.ua["SAFARI_IPHONE_WEBAPP_MODE"]
    assert Browser.safari?(ua)
  end

  test "detects ipod" do
    ua = Fixtures.ua["IPOD"]

    assert Browser.name(ua) == "iPod Touch"
    assert Browser.full_browser_name(ua) == "iPod Touch 3.0"
    assert Browser.full_display(ua) == "iPod Touch 3.0 on iOS"
    assert Browser.ipod?(ua)
    assert Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.mobile?(ua)
    assert Browser.modern?(ua)
    assert Browser.ios?(ua)
    refute Browser.tablet?(ua)
    refute Browser.mac?(ua)
    assert Browser.full_version(ua) == "3.0"
    assert Browser.version(ua) == "3"
  end

  test "detects ipad" do
    ua = Fixtures.ua["IPAD"]

    assert Browser.name(ua) == "iPad"
    assert Browser.full_browser_name(ua) == "iPad 4.0.4"
    assert Browser.full_display(ua) == "iPad 4.0.4 on iOS 3"
    assert Browser.ipad?(ua)
    assert Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.ios?(ua)
    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)
    refute Browser.mac?(ua)
    assert Browser.full_version(ua) == "4.0.4"
    assert Browser.version(ua) == "4"
  end

  test "detects ipad gsa" do
    ua = Fixtures.ua["IPAD_GSA"]

    assert Browser.name(ua) == "iPad"
    assert Browser.full_browser_name(ua) == "iPad 13.1.72140"
    assert Browser.full_display(ua) == "iPad 13.1.72140 on iOS 9"
    assert Browser.ipad?(ua)
    assert Browser.safari?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.ios?(ua)
    assert Browser.tablet?(ua)
    refute Browser.mobile?(ua)
    refute Browser.mac?(ua)
    assert Browser.full_version(ua) == "13.1.72140"
    assert Browser.version(ua) == "13"
  end

  test "detects ios4" do
    ua = Fixtures.ua["IOS4"]
    assert Browser.ios?(ua)
    assert Browser.ios?(ua, 4)
    refute Browser.mac?(ua)
  end


  test "detects ios5" do
    ua = Fixtures.ua["IOS5"]
    assert Browser.ios?(ua)
    assert Browser.ios?(ua, 5)
    refute Browser.mac?(ua)
  end

  test "detects ios6" do
    ua = Fixtures.ua["IOS6"]
    assert Browser.ios?(ua)
    assert Browser.ios?(ua, 6)
    refute Browser.mac?(ua)
  end

  test "detects ios7" do
    ua = Fixtures.ua["IOS7"]
    assert Browser.ios?(ua)
    assert Browser.ios?(ua, 7)
    refute Browser.mac?(ua)
  end

  test "detects ios8" do
    ua = Fixtures.ua["IOS8"]
    assert Browser.ios?(ua)
    assert Browser.ios?(ua, 8)
    refute Browser.mac?(ua)
  end

  test "detects ios9" do
    ua = Fixtures.ua["IOS9"]
    assert Browser.ios?(ua)
    assert Browser.ios?(ua, 9)
    refute Browser.mac?(ua)
  end

  test "don't detect as two ios different versions" do
    ua = Fixtures.ua["IOS8"]
    assert Browser.ios?(ua, 8)
    refute Browser.ios?(ua, 7)
  end

  # kindle
  test "detects kindle monochrome" do
    ua = Fixtures.ua["KINDLE"]

    assert Browser.kindle?(ua)
    assert Browser.webkit?(ua)
  end

  test "detects kindle fire" do
    ua = Fixtures.ua["KINDLE_FIRE"]

    assert Browser.kindle?(ua)
    assert Browser.webkit?(ua)
  end

  test "detects kindle fire hd" do
    ua = Fixtures.ua["KINDLE_FIRE_HD"]

    assert Browser.silk?(ua)
    assert Browser.kindle?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    refute Browser.mobile?(ua)
  end

  test "detects kindle fire hd mobile" do
    ua = Fixtures.ua["KINDLE_FIRE_HD_MOBILE"]

    assert Browser.silk?(ua)
    assert Browser.kindle?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    assert Browser.mobile?(ua)
  end

  # opera

  test "detects opera" do
    ua = Fixtures.ua["OPERA"]

    assert Browser.name(ua) == "Opera"
    assert Browser.full_browser_name(ua) == "Opera 11.64"
    assert Browser.full_display(ua) == "Opera 11.64 on MacOS 10.7.4 Lion"
    assert Browser.opera?(ua)
    refute Browser.modern?(ua)
    assert Browser.full_version(ua) == "11.64"
    assert Browser.version(ua) == "11"
  end

  test "detects opera next" do
    ua = Fixtures.ua["OPERA_NEXT"]

    assert Browser.name(ua) == "Opera"
    assert Browser.full_browser_name(ua) == "Opera 15.0.1147.44"
    assert Browser.full_display(ua) == "Opera 15.0.1147.44 on MacOS 10.8.4 Mountain Lion"
    assert Browser.id(ua) == :opera
    assert Browser.opera?(ua)
    assert Browser.webkit?(ua)
    assert Browser.modern?(ua)
    refute Browser.chrome?(ua)
    assert Browser.full_version(ua) == "15.0.1147.44"
    assert Browser.version(ua) == "15"
  end

  test "detects opera mini" do
    ua = Fixtures.ua["OPERA_MINI"]

    assert Browser.opera_mini?(ua)
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
  end

  test "detects opera mobi" do
    ua = Fixtures.ua["OPERA_MOBI"]

    assert Browser.opera?(ua)
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
  end

  # bug https://github.com/tuvistavie/elixir-browser/issues/13
  test "detects opera on android" do
    ua = Fixtures.ua["OPERA_ANDROID"]

    assert Browser.opera?(ua)
    assert Browser.android?(ua)
  end

  test "detects UC Browser" do
    ua = Fixtures.ua["UC_BROWSER"]

    assert Browser.name(ua) == "UC Browser"
    assert Browser.version(ua) == "8"
    assert Browser.uc_browser?(ua)
    refute Browser.tablet?(ua)
    assert Browser.mobile?(ua)
  end

  test "fallbacks to other on unknown UA" do
    ua = Fixtures.ua["INVALID"]

    assert Browser.name(ua) == "Other"
    assert Browser.full_browser_name(ua) == "Other 0.0"
    assert Browser.full_display(ua) == "Other 0.0 on Other"
    assert Browser.id(ua) == :other
    assert Browser.full_version(ua) == "0.0"
    assert Browser.version(ua) == "0"
  end
end
