#import "../chapters/pinout-tables.typ" as pins
#import "colours.typ" as colours

#let badge(colour, doc) = {
  set text(white)
  rect(fill: colour, doc)
}

#let callout(type, title, custom-title-colour: none, custom-body-colour: none, doc) = {

  let title_colour
  let body_colour

  if type == "warning" {
    title_colour = colours.WARNING_STRONG
    body_colour = colours.WARNING_WEAK

  } else if type == "danger" {
    title_colour = colours.DANGER_STRONG
    body_colour = colours.DANGER_WEAK

  } else if type == "info" {
    title_colour = colours.INFO_STRONG
    body_colour = colours.INFO_WEAK

  } else if type == "custom" {
    title_colour = custom-title-colour
    body_colour = custom-body-colour
    
  } else {
    panic([unknown callout type (#type)])
  }

  set text(white)

  block(fill: body_colour, width: 100%, inset: 8pt)[
    #block(fill: title_colour, width: 100%, outset: 8pt)[
      #strong(title)
    ]
    #doc
  ]
}

#let project(
  title: "Title", 
  author: "Author", 
  repo-link: "!!! missing repository link !!!", 
  description: [!!! Missing description !!!], 
  address: "0x0000", 
  clock: "No Clock", 
  type: "HDL",
  wokwi-id: none,
  danger-level: none,
  danger-reason: none,
  
  doc
) = {
  
  context {
    // make fake heading - this is the one that gets shown in the table of contents
    // which has the nice address marker next to it
    // 
    // width: page.width-2.5cm because a 2 line title was returning the wrong height
    // meaning it would overrun with the author line
    // NOTE: this might have to be tweaked a little more to get a good value

    // TODO: should width == 100%? is that easier and does that fix the problem?
    // 2025-09-15 -- it does not!! but i would love for it to work, so worth coming back at this
    let fake_heading = hide[#block(above: 0em, below: 0em, width: page.width - 1.8cm)[
          #heading(level: 2)[
              #box(baseline: 0.4em)[
                #rect(fill: colours.BADGE_TEAL)[
                  #text(white)[*#raw(address)*]
                ]
              ] #title
          ]
        #label(repo-link)
      ]
    ]

    let fake_heading_size = measure(fake_heading)
    [#fake_heading]

    // make real heading and move into position
    // this covers the fake one we just made
    place(
      dy: -fake_heading_size.height,
      heading(level: 2, outlined: false)[#title]
    )

    // display author names
    // if 1, it is displayed as is
    // if 2, it is displayed as "a & b"
    // if >2, it is displayed as "a, b & c"
    v(0.2em)
    let author_text = []
    author_text += [by *#author.at(0)*]

    if author.len() == 2 {author_text += [ & *#author.at(1)*]}
    else if author.len() > 2 {
      let names = author.slice(1, author.len()-1)
      for name in names {author_text += [, *#name*]}
      author_text += [ & *#author.at(author.len()-1)*]
    }
    author_text
  }

  let badges = (
    badge(colours.BADGE_TEAL, strong(raw(address))),
    badge(colours.BADGE_BLUE, strong(raw(clock))),
    badge(colours.BADGE_PINK, strong(raw(type + " Project")))
  )

  let danger_callout = none

  if danger-level != none {
    if danger-level == "medium" {
      badges.push(badge(colours.WARNING_STRONG)[*`Medium Danger`*])

      danger_callout = callout("warning", raw("This project can damage the ASIC under certain conditions."), raw(danger-reason))

    } else if danger-level == "high" {
      badges.push(badge(colours.DANGER_STRONG)[*`High Danger`*])

      danger_callout = callout("danger", raw("This project will damage the ASIC."), raw(danger-reason))
    } else {
      panic([unexpected danger-level value (#danger-level)])
    }
  }

  grid(
    columns: badges.len(),
    column-gutter: 1em,

    // ffc936 good colour
    // NOTE: height retrieved from measure(rectangle), currently hardcoded
    // TODO: encase in context to calculate it all properly
    // rect(fill: rgb(0, 150, 150), height: 18.4pt)[#text(white)[*#raw(address)*]],
    // rect(fill: rgb("#3e71e7"))[#text(white)[*#raw(clock)*]],
    // rect(fill: rgb("#db44b2"))[#text(white)[*#raw(type) `Project`*]],
    // rect(fill: rgb("#e63333"))[#text(white)[github.com]]

    ..badges
    // badge(rgb(0, 150, 150), strong(raw(address))),
    // badge(rgb("#3e71e7"), strong(raw(clock))),
    // badge(rgb("#db44b2"), strong(raw(type + " Project")))
  )

  {
    show "https://": ""
    link(repo-link)[#raw(repo-link)]

    if wokwi-id != none {
      let wokwi_link = "https://wokwi.com/projects/" + wokwi-id
      link(wokwi_link)[\ #raw(wokwi_link)]
    }
  }


  align(center)[
    "#emph(description)"
  ]

  set heading(offset: 2)
  danger_callout

  doc
  pagebreak(weak: true)
}

#let splash_chapter_page(title, colour, invert-text-colour: false, footer-text: none) = {
  set page(fill: colour)
  set text(white) if invert-text-colour

  set page(
    footer: {
      set text(size: 10pt)
      // set text(white) if invert-text-colour

      let logo = if invert-text-colour {
        image("/resources/logos/tt-logo-white.svg", height: 25%)
      } else {
        image("/resources/logos/tt-logo-black.svg", height: 25%)
      }

      box(baseline: 0.25em, logo)

      h(0.25cm)
      emph(footer-text)

      h(1fr)

      // get the title of the current chapter
      emph(context query(selector(heading.where(level: 1)).before(here())).last().body)
      h(0.5cm)
      context strong(counter(page).display("1"))
    }
  )

  align(center + horizon)[
    #context {
      let hidden_heading = hide(heading(level: 1, title))
      let hidden_heading_size = measure(hidden_heading)
      [#hidden_heading]
      place(
        // dy: -big_heading_size.height,
        dy: -2.5cm,
        text(size: 100pt)[
          *#title*
        ]
      )
    }
  ]

  set page(fill: none)
  pagebreak(weak: true)
}

#let _funding_content = state("_funding_content", [])
#let _funding_alt_title = state("_funding_alt_title", [])

#let datasheet(
  shuttle: none,
  repo-link: none,
  theme: "classic",
  projects: none,
  show-pinouts: "latest",
  theme-override-colour: none,
  date: datetime.today(),
  link-disable-colour: true,
  link-override-colour: none,

  doc
) = {

  set document(
    title: [Tiny Tapeout #shuttle Datasheet]
    // TODO:
    // author: "?",
    // description: "?",
    // keywords: "?"
  )

  set page(
    paper: "a4",
    margin: auto,
    )
  set text(font: "Montserrat", size: 12pt)

  show raw: set text(font: "Martian Mono", weight: "light")

  // let date_str = datetime.today().display("[month repr:long] [day padding:none], [year]")
  let date_str = date.display("[month repr:long] [day padding:none], [year]")


  // make titlepage
  if theme == "classic" {
    image("/resources/logos/tt-logo-colourful.png")

    align(center)[
      #text(size: 32pt)[*Tiny Tapeout #shuttle Datasheet*]

      #set text(size: 16pt)
      // make url pretty without having to explicitly pass it
      #show "https://": ""
      #link(repo-link)[#raw(repo-link)]

      #v(2.5cm)
      #date_str
    ]
  } else if theme == "bold" {
    set page(fill: colours.THEME_PLUM) // default fill for bold theme
    set page(fill: theme-override-colour) if theme-override-colour != none

    align(center+horizon)[#image("/resources/logos/tt-logo-white.svg", height: 60%)]

    align(center)[
      #text(size:32pt, white)[*Tiny Tapeout #shuttle Datasheet*]

      #text(size: 16pt, weight: "medium", white)[
        #show "https://": ""
        #link(repo-link)[#raw(repo-link)]
        #v(2.5cm)
        #date_str
      ]
    ] 
  } else if theme == "monochrome" {
    align(center+horizon)[#image("/resources/logos/tt-logo-black.svg", height: 60%)]

    align(center)[
      #text(size:32pt)[*Tiny Tapeout #shuttle Datasheet*]

      #text(size: 16pt, weight: "medium")[
        #show "https://": ""
        #link(repo-link)[#raw(repo-link)]
        #v(2.5cm)
        #date_str
      ]
    ] 
  }

  // format link colour
  // moved after title page since theme-override-colour would cause it to blend in with the background
  let link_colour = luma(0%) // TODO: get default colour using context?
  if not link-disable-colour {
    link_colour = colours.LINK_DEFAULT
    if link-override-colour != none {
      link_colour = link-override-colour
    }
  }
  show link: this => {
    text(link_colour, this)
  }

  // make tiling logo page after cover
  [
    #let pattern = tiling(
      size: (3cm, 3cm),
      spacing: (1cm, 1cm)
    )[
      #image("/resources/logos/tt-logo-light-grey.svg", width: 100%)
    ]
    #set page(      
      // background: rect(width:100%, height: 100%, fill: pattern))
      background: rotate(0deg, rect(width: 110%, height: 105%, inset: 0pt, outset: 0pt, stroke: none, fill: pattern))
    )
    #pagebreak(to: "odd")
  ]

  show heading.where(level: 1): set text(size: 28pt)
  show heading.where(level: 2): set text(size: 22pt)
  show heading.where(level: 3): set text(size: 16pt)


  // set footer page counter just for table of contents
  set page(
    footer: {
      set text(size: 10pt)
      align(right)[
        #context strong(counter(page).display("i"))
      ]
    }
  )

  // make table of contents
  counter(page).update(1)
  show outline.entry.where(level: 1): this => {
    set block(above: 1em)
    strong(this)
  }
  outline(depth: 2, title: text(size: 24pt)[Table of Contents #v(1em)])
  pagebreak(weak: true)


  if doc != [] {
      pagebreak(weak: true)
      counter(page).update(1)
  }

  set page(
    footer: {
      set text(size: 10pt)

      box(baseline: 0.25em)[
          #image("/resources/logos/tt-logo-black.svg", height: 25%)
      ]

      h(0.25cm)
      emph(shuttle)

      h(1fr)

      // get the title of the current chapter
      emph(context query(selector(heading.where(level: 1)).before(here())).last().body)
      h(0.5cm)
      context strong(counter(page).display("1"))
    }
  )

  // indent numbered and bullet point lists
  set enum(indent: 1em)
  set list(indent: 1em)

  // format table so that empty cells show dark grey em dash
  show table.cell: this => {
    if this.body == [] {
        align(center + horizon, text(fill: colours.TABLE_GREY)[$dash.em$])
    } else {
      this
    }
  }


  // make funding/sponsor page
  context {
    let funding = _funding_content.final()
    let alt_title = _funding_alt_title.final()

    if funding != [] {
      if alt_title != none {
        heading(level: 1, alt_title)
      } else {
        heading(level: 1, "Funding")
      }

      funding
      pagebreak(weak: true)
    }
  }

  include "../chapters/team.typ"
  pagebreak(weak: true)
  include "../chapters/pinout.typ"
  pagebreak(weak: true)
  include "../chapters/tt-multiplexer.typ"
  
  if show-pinouts == "caravel" {
    align(center, pins.caravel)
    pins.dagger_legend
  } else if show-pinouts == "latest" {
    align(center, pins.new_frame)
    pins.dagger_legend
  } else {
    panic([unknown pinout table referenced (#show-pinouts)])
  }

  // make project splash page
  if theme == "bold" {
    if theme-override-colour != none {
      splash_chapter_page("Projects", theme-override-colour, invert-text-colour: true, footer-text: shuttle)
    } else {
      splash_chapter_page("Projects", colours.THEME_PLUM, invert-text-colour: true, footer-text: shuttle)
    }
  } else {
    splash_chapter_page("Projects", white, footer-text: shuttle)
  }

  if projects != none {
    projects
  }

  doc
}

#let funding(doc, alt-title: none) = {
  context {
    _funding_content.update(doc)
    _funding_alt_title.update(alt-title)
  }
  
}