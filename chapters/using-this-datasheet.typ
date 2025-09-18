#import "../src/datasheet.typ": badge, callout
#import "../src/colours.typ" as colours


= Using This Datasheet

== Structure
Projects are ordered by their mux address, in ascending order. Documentation is user-provided from their GitHub
repositories and are merged into the final shuttle once the deadline is reached.

In general, each project should contain:
- the user-provided title & a list of authors
- a link to the GitHub repository used for submission
- a link to the Wokwi project (if applicable)
- a "How it works" section
- a "How to test" section
- an "External hardware" section (if applicable)
- a pinout table for both digital & analog designs

== Badges
This datasheet uses "badges" to quickly convey some information about the project. A selection of these badges are available below.

#let example_address_badge = box(baseline: 0.4em, badge(colours.BADGE_TEAL, strong(raw("-123"))))
#let example_microtile_addr_badge = box(baseline: 0.4em, badge(colours.BADGE_TEAL, strong(raw("-423/2"))))
#let example_clock_badge = box(baseline: 0.4em, badge(colours.BADGE_BLUE, strong(raw("25.175 MHz"))))
#let example_proj_wokwi = box(baseline: 0.4em, badge(colours.BADGE_PINK, strong(raw("Wokwi Project"))))
#let example_proj_hdl = box(baseline: 0.4em, badge(colours.BADGE_PINK, strong(raw("HDL Project"))))
#let example_proj_analog = box(baseline: 0.4em, badge(colours.BADGE_PINK, strong(raw("Analog Project"))))
#let example_proj_analog = box(baseline: 0.4em, badge(colours.BADGE_PINK, strong(raw("Analog Project"))))
#let example_medium_danger = box(baseline: 0.4em, badge(colours.WARNING_STRONG, strong(raw("Medium Danger"))))
#let example_high_danger = box(baseline: 0.4em, badge(colours.DANGER_STRONG, strong(raw("High Danger"))))



#table(
  columns: 2,
  rows: 4,
  inset: 6pt,
  align: (center + horizon, left),

  table.header(
    [Badge], [Description]
  ),

  [#example_address_badge \ #example_microtile_addr_badge], [Mux address of the project, in decimal. For microtile designs, their sub-address is placed after the forward slash. In this example, it would be `2`.],
  example_clock_badge, [Clock frequency of the project. May be truncated from actual value or omitted completely.],
  [#example_proj_hdl \ #example_proj_wokwi \ #example_proj_analog], [Project type, indicating if it was made with a HDL, Wokwi, or if it is analog.],
  [#example_medium_danger \ #example_high_danger], [Indicates the risk that the project presents to the ASIC. Medium danger projects can damage the ASIC under certain conditions, whilst high danger projects _will_ damage the ASIC.]
)

== Callouts
In addition to #example_medium_danger and #example_high_danger badges being used, a callout is placed before the project documentation begins to alert the user.

A callout for #example_medium_danger may look something like:
#callout("warning", 
  `This project will damage the ASIC under certain conditions.`, 
  `There is an error in the schematic which may lead to ASIC failure under certain clocking conditions.`
)

Similarly, a callout for #example_high_danger may look something like:
#callout("danger",
  `This project will damage the ASIC.`,
  `There is an error in the schematic which may cause permanent damage when powered on in a certain configuration.`
)

Should there be a project that poses a danger, the callout will explain the reasoning behind the danger level.

Callouts may also provide some additional information, and look something like so:
#callout("info",
  `Information`,
  raw("Silicon melts at 1414°C, and boils at 3265°C. Don't let your chip get too hot!")
)