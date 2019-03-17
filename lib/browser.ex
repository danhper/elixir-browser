defmodule Browser do
  import Browser.Helpers, only: [to_int: 1]

  defprotocol Ua do
    @type ua :: String.t
    @spec to_ua(any) :: ua
    def to_ua(input)
  end

  defimpl Ua, for: BitString do
    def to_ua(string), do: string
  end

  defimpl Ua, for: Plug.Conn do
    def to_ua(conn) do
      conn
      |> Plug.Conn.get_req_header("user-agent")
      |> case do
        []     -> ""
        [h|_t] -> h
      end
    end
  end

  # order is important, so we need a keyword list, not a map
  @names [
    edge: "Microsoft Edge",   # Must come before everything
    ie: "Internet Explorer",  # Must come before android
    chrome: "Chrome",         # Must come before android
    firefox: "Firefox",       # Must come before android
    uc_browser: "UC Browser", # Must come before android
    android: "Android",
    blackberry_running_safari: "Safari",
    blackberry: "BlackBerry",
    core_media: "Apple CoreMedia",
    ipad: "iPad",             # Must come before safari
    iphone: "iPhone",         # Must come before safari
    ipod: "iPod Touch",       # Must come before safari
    nintendo: "Nintendo",
    opera: "Opera",
    phantom_js: "PhantomJS",
    psp: "PlayStation Portable",
    playstation: "PlayStation",
    quicktime: "QuickTime",
    safari: "Safari",
    xbox: "Xbox",

    other: "Other",
  ]

  @versions %{
    edge: ~r{Edge/([\d.]+)},
    chrome: ~r{(?:Chrome|CriOS)/([\d.]+)},
    default: ~r{(?:Version|MSIE|Firefox|QuickTime|BlackBerry[^/]+|CoreMedia v|PhantomJS|AdobeAIR|GSA|UCBrowser)[/ ]?([a-z0-9.]+)}i,
    opera: ~r{(?:Opera/.*? Version/([\d.]+)|Chrome/.*?OPR/([\d.]+))},
    ie: ~r{(?:MSIE |Trident/.*?; rv:)([\d.]+)}
  }

  @modern_rules [
    &Browser.webkit?/1,
    &Browser.modern_firefox?/1,
    &Browser.modern_ie_version?/1,
    &Browser.modern_edge?/1,
    &Browser.modern_opera?/1,
    &Browser.modern_firefox_tablet?/1
  ]

  # Common

  def detect_version?(actual_version, expected_version) do
    if is_nil(expected_version) do
      true
    else
      String.starts_with?(to_string(actual_version), to_string(expected_version))
    end
  end

  def name(input) do
    @names[id(input)]
  end

  def full_browser_name(input) do
    [
      name(input),
      full_version(input)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(fn(x) -> x |> String.trim |> String.length == 0 end)
    |> Enum.join(" ")
  end

  def full_platform_name(input) do
    case platform(input) do
      :ios -> ["iOS", ios_version(input)]
      :android -> ["Android", android_version(input)]
      :linux -> "Linux"
      :mac -> ["MacOS", mac_version(input), mac_version_name(input)]
      :windows -> ["Windows", windows_version_name(input)]
      :chrome_os -> "ChromeOS"
      :blackberry -> ["BlackBerry", blackberry_version(input)]
      :other -> "Other"
    end
    |> List.wrap
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(fn(x) -> x |> String.trim |> String.length == 0 end)
    |> Enum.join(" ")
  end

  def full_display(input) do
    [
      full_browser_name(input),
      full_platform_name(input)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(fn(x) -> x |> String.trim |> String.length == 0 end)
    |> Enum.join(" on ")
  end

  def id(input) do
    ua = Ua.to_ua(input)
    @names |> Keyword.keys |> Enum.find(fn id ->
      f = String.to_atom("#{id}?")
      if function_exported?(Browser, f, 1) do
        apply(Browser, f, [ua])
      else
        id
      end
    end)
  end

  def version(input) do
    ua = Ua.to_ua(input)
    if ie?(ua) do
      ie_version(ua)
    else
      ua |> full_version |> to_string |> String.split(".") |> List.first
    end
  end

  def full_version(input) do
    ua = Ua.to_ua(input)
    if ie?(ua) do
      ie_full_version(ua)
    else
      Map.get(@versions, id(ua), @versions[:default])
        |> Regex.run(ua)
        |> Kernel.||([])
        |> Enum.drop(1)
        |> Enum.filter(fn n -> is_bitstring(n) and String.length(n) > 0 end)
        |> List.first || "0.0"
    end
  end

  def modern?(input) do
    ua = Ua.to_ua(input)
    Enum.any? @modern_rules, fn f -> f.(ua) end
  end

  def modern_firefox?(ua) do
    Browser.firefox?(ua) and to_int(Browser.version(ua)) >= 17
  end

  def modern_ie_version?(ua) do
    Browser.ie?(ua) and to_int(Browser.version(ua)) >= 9 and !Browser.compatibility_view?(ua)
  end

  def modern_edge?(ua) do
    Browser.edge?(ua) and !Browser.compatibility_view?(ua)
  end

  def modern_opera?(ua) do
    Browser.opera?(ua) and to_int(Browser.version(ua)) >= 12
  end

  def modern_firefox_tablet?(ua) do
    Browser.firefox?(ua) and Browser.tablet?(ua) and Browser.android?(ua) and to_int(Browser.version(ua)) >= 14
  end

  def webkit?(input) do
    ua = Ua.to_ua(input)
    String.match?(ua, ~r/AppleWebKit/i) and !edge?(ua)
  end

  def quicktime?(input) do
    input |> Ua.to_ua |> String.match?(~r/QuickTime/i)
  end

  def core_media?(input) do
    input |> Ua.to_ua |> String.match?(~r/CoreMedia/i)
  end

  def phantom_js?(input) do
    input |> Ua.to_ua |> String.match?(~r/PhantomJS/i)
  end

  def safari?(input) do
    ua = Ua.to_ua(input)
    other_match = ~r/Android|Chrome|CriOS|PhantomJS/
    (String.match?(ua, ~r/Safari/) or safari_webapp_mode?(ua)) and not String.match?(ua, other_match)
  end

  def safari_webapp_mode?(input) do
    (ipad?(input) or iphone?(input)) and (input |> Ua.to_ua |> String.match?(~r/AppleWebKit/))
  end

  def firefox?(input) do
    input |> Ua.to_ua |> String.match?(~r/Firefox/)
  end

  def chrome?(input) do
    (input |> Ua.to_ua |> String.match?(~r/(Chrome|CriOS)/)) and !opera?(input) and !edge?(input)
  end

  def opera?(input) do
    input |> Ua.to_ua |> String.match?(~r/(Opera|OPR)/)
  end

  def uc_browser?(input) do
    input |> Ua.to_ua |> String.match?(~r/(UCBrowser)/)
  end

  def silk?(input) do
    input |> Ua.to_ua |> String.match?(~r/Silk/)
  end

  def yandex?(input) do
    input |> Ua.to_ua |> String.match?(~r/YaBrowser/)
  end

  def known?(input) do
    id(input) != :other
  end

  # Blackberry

  def blackberry_version(input) do
    ua = Ua.to_ua(input)
    (Regex.run(~r/BB(10)/, ua) ||
     Regex.run(~r/BlackBerry\d+\/(\d+)/, ua) ||
     Regex.run(~r/BlackBerry.*?Version\/(\d+)/, ua) || []) |> Enum.at(1)
  end

  def blackberry?(input, version \\ nil) do
    (input |> Ua.to_ua |> String.match?(~r/(BlackBerry|BB10)/)) and
      detect_version?(blackberry_version(input), version)
  end

  def blackberry_running_safari?(input) do
    blackberry?(input) && safari?(input)
  end

  # Bot
  @bots_file Application.get_env(:browser, :bots_file, "bots.txt")
  @bots Browser.Helpers.read_file(@bots_file)
  @search_engines Browser.Helpers.read_file("search_engines.txt")

  def bot?(input, options \\ []) do
    ua = Ua.to_ua(input) |> String.downcase
    bot_with_empty_ua?(ua, options) ||
      Enum.any? @bots, fn {name, _} -> String.contains?(ua, name) end
  end

  def bot_name(input, options \\ []) do
    ua = Ua.to_ua(input) |> String.downcase

    if bot_with_empty_ua?(ua, options) do
      "Generic Bot"
    else
      res = Enum.find @bots, fn {name, _} -> String.contains?(ua, name) end
      elem(res || {nil, nil}, 0)
    end
  end

  def search_engine?(input) do
    ua = Ua.to_ua(input) |> String.downcase
    Enum.any? @search_engines, fn {name, _} -> String.contains?(ua, String.downcase(name)) end
  end

  defp bot_with_empty_ua?(ua, options) do
    options[:detect_empty_ua] && String.trim(ua) == ""
  end

  # Consoles

  def xbox?(input) do
    input |> Ua.to_ua |> String.match?(~r/xbox/i)
  end

  def xbox_one?(input) do
    input |> Ua.to_ua |> String.match?(~r/xbox one/i)
  end

  def playstation?(input) do
    input |> Ua.to_ua |> String.match?(~r/playstation/i)
  end

  def playstation4?(input) do
    input |> Ua.to_ua |> String.match?(~r/playstation 4/i)
  end

  def nintendo?(input) do
    input |> Ua.to_ua |> String.match?(~r/nintendo/i)
  end

  def console?(input) do
    xbox?(input) or playstation?(input) or nintendo?(input)
  end

  def psp?(input) do
    (input |> Ua.to_ua |> String.match?(~r/PSP/)) or psp_vita?(input)
  end

  def psp_vita?(input) do
    input |> Ua.to_ua |> String.match?(~r/Playstation Vita/)
  end

  # Devices

  def iphone?(input) do
    input |> Ua.to_ua |> String.match?(~r/iPhone/)
  end

  def ipad?(input) do
    input |> Ua.to_ua |> String.match?(~r/iPad/)
  end

  def ipod?(input) do
    input |> Ua.to_ua |> String.match?(~r/iPod/)
  end

  def surface?(input) do
    windows_rt?(input) and (input |> Ua.to_ua |> String.match?(~r/Touch/))
  end

  def tablet?(input) do
    ipad?(input) or (android?(input) and not detect_mobile?(Ua.to_ua(input))) or surface?(input) or playbook?(input)
  end

  def kindle?(input) do
    (input |> Ua.to_ua |> String.match?(~r/(Kindle)/)) or silk?(input)
  end

  def playbook?(input) do
    ua = Ua.to_ua(input)
    String.match?(ua, ~r/PlayBook/) and String.match?(ua, ~r/RIM Tablet/)
  end

  def windows_touchscreen_desktop?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/Touch/))
  end

  def device_type(input) do
    cond do
      mobile?(input) -> :mobile
      tablet?(input) -> :tablet
      console?(input) -> :console
      known?(input) -> :desktop
      true -> :unknown
    end
  end

  # IE
  @trident_version_regex ~r{Trident/([0-9.]+)}
  @modern_ie ~r{Trident/.*?; rv:(.*?)}
  @msie ~r{MSIE ([\d.]+)|Trident/.*?; rv:([\d.]+)}
  @edge ~r{(Edge/[\d.]+|Trident/8)}
  @trident_mapping %{
    "4.0" => "8",
    "5.0" => "9",
    "6.0" => "10",
    "7.0" => "11",
    "8.0" => "12"
  }

  def ie?(input, version \\ nil) do
    ua = Ua.to_ua(input)
    (msie?(ua) or modern_ie?(ua)) && detect_version?(ie_version(ua), version)
  end

  def edge?(input) do
    input |> Ua.to_ua |> String.match?(@edge)
  end

  defp ie_version(ua) do
    Map.get(@trident_mapping, trident_version(ua), msie_version(ua))
  end

  defp trident_version(ua) do
    (Regex.run(@trident_version_regex, ua) || []) |> Enum.at(1)
  end

  defp ie_full_version(ua) do
    "#{ie_version(ua)}.0"
  end

  def msie_version(ua) do
    v = msie_full_version(ua) |> String.split(".") |> List.first
    if String.length(v) > 0, do: v, else: "0"
  end

  def msie_full_version(input) do
    ua = Ua.to_ua(input)
    if res = Regex.run(@msie, ua) do
      first_match = Enum.at(res, 1)
      if first_match && String.length(first_match) > 0, do: first_match, else: Enum.at(res, 2) || "0.0"
    else
      "0.0"
    end
  end

  def compatibility_view?(input) do
    ua = Ua.to_ua(input)
    ie?(ua) && trident_version(ua) && to_int(msie_version(ua)) < (to_int(trident_version(ua)) + 4)
  end

  defp modern_ie?(ua) do
    Regex.match?(@modern_ie, ua)
  end

  defp msie?(ua) do
    Regex.match?(~r/MSIE/, ua) and not Regex.match?(~r/Opera/, ua)
  end

  # Mobile

  def mobile?(input) do
    detect_mobile?(Ua.to_ua(input)) and not tablet?(input)
  end

  def opera_mini?(input) do
    input |> Ua.to_ua |> String.match?(~r/Opera Mini/)
  end

  def adobe_air?(input) do
    input |> Ua.to_ua |> String.match?(~r/adobeair/i)
  end

  defp detect_mobile?(ua) do
    psp?(ua) or
    String.match?(ua, ~r/zunewp7/i) or
    String.match?(ua, ~r/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i) or
    String.match?(String.slice(ua, 0, 4), ~r/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i)
  end

  # Platform

  def android?(input, version \\ nil) do
    ua = Ua.to_ua(input)
    String.match?(ua, ~r/Android/) and detect_version?(android_version(ua), version)
  end

  def android_version(input) do
    Enum.at(Regex.run(~r/Android ([\d.]+)/, Ua.to_ua(input)) || [], 1)
  end

  def ios?(input, version \\ nil) do
    ua = Ua.to_ua(input)
    (ipod?(ua) || ipad?(ua) || iphone?(ua)) and detect_version?(ios_version(ua), version)
  end

  def ios_version(input) do
    Enum.at(Regex.run(~r/OS (\d+)/, Ua.to_ua(input)) || [], 1)
  end

  def mac?(input) do
    (input |> Ua.to_ua |> String.match?(~r/Mac OS X/)) and not ios?(input)
  end

  def mac_version(input) do
    case Enum.at(Regex.run(~r/Mac OS X ([\d\.\_]+)/, Ua.to_ua(input)) || [], 1) do
      nil -> ""
      version -> String.replace(version, "_", ".")
    end
  end

  def mac_version_name(input) do
    case Enum.at(Regex.run(~r/(\d+\.\d+)/, mac_version(input)) || [], 1) do
      "10.14" -> "Mojave"
      "10.13" -> "High Sierra"
      "10.12" -> "Sierra"
      "10.11" -> "El Capitan"
      "10.10" -> "Yosemite"
      "10.9" -> "Mavericks"
      "10.8" -> "Mountain Lion"
      "10.7" -> "Lion"
      "10.6" -> "Snow Leopard"
      "10.5" -> "Leopard"
      "10.4" -> "Tiger"
      "10.3" -> "Panther"
      "10.2" -> "Jaguar"
      "10.1" -> "Puma"
      "10.0" -> "Cheetah"
      _ -> ""
    end
  end

  def windows?(input) do
    input |> Ua.to_ua |> String.match?(~r/(Windows)/)
  end

  def windows_version_name(input) do
    cond do
      windows_rt?(input) -> "RT"
      windows_mobile?(input) -> "Mobile"
      windows_phone?(input) -> "Phone"
      windows_xp?(input) -> "XP"
      windows_vista?(input) -> "Vista"
      windows7?(input) -> "7"
      windows8_1?(input) -> "8.1"
      windows8?(input) -> "8"
      windows10?(input) -> "10"
      true -> ""
    end
  end

  def windows_xp?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/(Windows NT 5\.1)/))
  end

  def windows_vista?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/(Windows NT 6\.0)/))
  end

  def windows7?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/(Windows NT 6\.1)/))
  end

  def windows8?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/(Windows NT 6\.[2-3])/))
  end

  def windows8_1?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/(Windows NT 6\.3)/))
  end

  def windows10?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/(Windows NT 10)/))
  end

  def windows_rt?(input) do
    windows8?(input) and (input |> Ua.to_ua |> String.match?(~r/(ARM)/))
  end

  def windows_mobile?(input) do
    input |> Ua.to_ua |> String.match?(~r/Windows CE/)
  end

  def windows_phone?(input) do
    input |> Ua.to_ua |> String.match?(~r/Windows Phone/)
  end

  def windows_x64?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/x64/))
  end

  def windows_wow64?(input) do
    windows?(input) and (input |> Ua.to_ua |> String.match?(~r/WOW64/i))
  end

  def windows_x64_inclusive?(input) do
    windows_x64?(input) or windows_wow64?(input)
  end

  def linux?(input) do
    input |> Ua.to_ua |> String.match?(~r/Linux/)
  end

  def chrome_os?(input) do
    input |> Ua.to_ua |> String.match?(~r/CrOS/)
  end

  def platform(input) do
    cond do
      ios?(input) -> :ios
      android?(input) -> :android
      linux?(input) -> :linux
      mac?(input) -> :mac
      windows?(input) -> :windows
      chrome_os?(input) -> :chrome_os
      blackberry?(input) -> :blackberry
      true -> :other
    end
  end

  # TV

  def tv?(input) do
    input |> Ua.to_ua |> String.match?(~r/(tv|Android.*?ADT-1|Nexus Player)/i)
  end
end
