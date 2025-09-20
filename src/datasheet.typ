#import "@preview/tiaoma:0.3.0"
#import "../chapters/pinout-tables.typ" as pins
#import "colours.typ" as colours

#let _funding_content = state("_funding_content", [])
#let _funding_alt_title = state("_funding_alt_title", [])
#let _flip_footer_ordering = state("_flip_footer_ordering", false)
#let _chip_render_content = state("_chip_render_content", none)
#let _chip_render_sponsor_text = state("_chip_render_sponsor_text", none)
#let _chip_render_sponsor_logo = state("_chip_render_sponsor_logo", none)

#let _footer(shuttle, invert-text-colour: false, display-pg-as: "1", flip-ordering: false) = {
  // setup
  set text(size: 10pt)
  set text(white) if invert-text-colour

  let logo = box(baseline: 0.25em, {
    if invert-text-colour {
      image("/resources/logos/tt-logo-white.svg", height: 25%)
    } else {
      image("/resources/logos/tt-logo-black.svg", height: 25%)
    }
  })

  // get the title of the current chapter
  let title = context query(selector(heading.where(level: 1)).before(here())).last().body
  let pg_num = context counter(page).display(display-pg-as)

  let TITLE_SPACING = 0.5cm
  let LOGO_SPACING = 0.25cm

  let set_1 = {strong(pg_num); h(TITLE_SPACING); emph(title);  h(1fr);  emph(shuttle); h(LOGO_SPACING); logo}
  let set_2 = {logo; h(LOGO_SPACING); emph(shuttle);  h(1fr);  emph(title); h(TITLE_SPACING); strong(pg_num)}

  // actual styling
  context {
    // alternate odd-even pages
    if calc.even(counter(page).get().first()) {
      if flip-ordering {
        set_2
      } else {
        set_1
      }
      // strong(pg_num); h(TITLE_SPACING); emph(title);  h(1fr);  emph(shuttle); h(LOGO_SPACING); logo

    } else {
      if flip-ordering {
        set_1
      } else {
        set_2
      }
      // logo; h(LOGO_SPACING); emph(shuttle);  h(1fr);  emph(title); h(TITLE_SPACING); strong(pg_num)
    }
  }

}

// NOTE: any "-" characters will get converted into coloured zeroes
#let badge(colour, doc) = {
  set text(white)
  show "-": this => {
    set text(colours.BADGE_MUTED_TEAL)
    [0]
  }
  rect(fill: colour, doc)
}

#let callout(type, title, custom-title-colour: none, custom-body-colour: none, doc) = {

  set par(justify: false)
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
  address: "----", 
  clock: "No Clock", 
  type: "HDL",
  wokwi-id: none,
  danger-level: none,
  danger-reason: none,
  
  doc
) = {
  
  // make fake heading - this is the one that gets shown in the table of contents
  // which has the nice address marker next to it
  let fake_heading = block(      
    heading(level: 2, outlined: true, bookmarked: false)[
      #box(baseline: 0.4em, badge(colours.BADGE_TEAL, strong(raw(address))))
      #title
    ]
  )
  
  // move fake heading so it doesn't affect layout
  place(top + left, hide(fake_heading))

  // make heading thats seen on the project page
  heading(level: 2, outlined: false, bookmarked: true, title)


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

  let badges = (badge(colours.BADGE_TEAL, strong(raw(address))),)
  if not clock == "No Clock" {
    badges.push(badge(colours.BADGE_BLUE, strong(raw(clock))))
  }
  badges.push(badge(colours.BADGE_PINK, strong(raw(type + " Project"))))


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
    ..badges // unpack badges array
  )

  {
    // hardcode these repo links to be black
    // and not follow link-override-colour
    link(repo-link, text(black, raw(repo-link.trim("https://", at: start))))

    if wokwi-id != none {
      let wokwi_link = "https://wokwi.com/projects/" + wokwi-id
      parbreak()
      link(wokwi_link, text(black, raw(wokwi_link.trim("https://", at: start))))
    }
  }


  align(center)[
    "#emph(description)"
  ]

  danger_callout

  set heading(offset: 2)
  doc

  pagebreak(weak: true)
}

#let splash_chapter_page(title, page-colour: white, invert-text-colour: false, footer-text: none, additional-content: none) = {
  set page(fill: page-colour)
  set text(white) if invert-text-colour

  set page(footer: context {
    _footer(footer-text, invert-text-colour: invert-text-colour, flip-ordering: _flip_footer_ordering.final())
  })

  align(center + horizon)[
    #block(text(size: 100pt, strong(title)))
  ]

  let h = heading(level: 1, title)
  context {
    let h_size = measure(h)
    place(
      dy: -h_size.height,
      hide(h)
    )
  }

  if additional-content != none {
    set text(black)

    place(
      center + bottom,
      block(fill: white, inset: 10pt, additional-content)
    )
  }

  set page(fill: none)
  pagebreak(weak: true)
}

#let annotated-qrcode(url, title, title-colour: black, url-colour: black, tiaoma-args: (:)) = {
  let qr = tiaoma.qrcode(url, options: tiaoma-args)

  grid(
    columns: 1,
    rows: 3,
    align: center + horizon,
    row-gutter: 1em,

    text(fill: title-colour, title),
    qr,

    // make url be the width of the QR code
    context {
      block(
        width: measure(qr).width, 
        height: auto, 
        breakable: false, 
        link(url, text(url-colour, url.trim("https://", at: start))))
    }
  )
}

// make a tiling logo page
#let tiling-logo-page() = {

  let pattern = tiling(
    size: (3cm, 3cm),
    spacing: (1cm, 1cm),
    image("/resources/logos/tt-logo-light-grey.svg")
  )

  page(
    background: rotate(
      0deg,
      rect(width: 110%, height: 105%, inset: 0pt, outset: 0pt, stroke: none, fill: pattern)
    ),
    pagebreak(to: "odd")
  )
}

#let call-to-action-page(page-fill: white, body-text-colour: black, qrcode-colour: black) = {

  page(
    fill: page-fill,
    footer: none,
  )[
    
    #set text(body-text-colour)
    #align(center)[
      #heading(level: 1)[Where is #emph(underline("your")) design?]
      *Go from idea to chip design in minutes, without breaking the bank.*
    ]

    Interested and want to get your own design manufactured? Visit our website and
    check out our educational material and previous submissions!

    #align(center, heading(level: 2, outlined: false)[How?])
    New to this? Use our basic Wokwi template to see what's possible. If you're ready for more,
    use our advanced Wokwi template and unlock some extra pins.

    Know Verilog and CocoTB? Get stuck in with our HDL templates.

    #align(center, heading(level: 2, outlined: false)[When?])
    Multiple shuttles are run per year, meaning you've got an opportunity to manufacture your design
    at any time.

    #align(center, heading(level: 2, outlined: false)[Stuck? Need help? Want inspiration?])
    Come chat to us and our community on Discord! Scan the QR code below.
    
    #v(1cm)
    #grid(
      columns: (1fr, 1fr, 1fr),
      rows: 1,
      column-gutter: 1em,
      align: center,
      inset: 8pt,
      fill: white,

      annotated-qrcode("https://tinytapeout.com", "website", tiaoma-args: ("scale": 2.0, "fg-color": qrcode-colour)),
      annotated-qrcode("https://tinytapeout.com/digital_design", "digital design guide", tiaoma-args: ("scale": 1.75, "fg-color": qrcode-colour)),
      annotated-qrcode("https://tinytapeout.com/discord", "discord server", tiaoma-args: ("scale": 2.0, "fg-color": qrcode-colour))
    )
  ]
}

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
  chip-viewer-link: none,
  qrcode-follows-theme: false,

  doc
) = {

  set document(
    title: [Tiny Tapeout #shuttle Datasheet]
    // TODO:
    // author: "?",
    // description: "?",
    // keywords: "?"
  )

  set page(paper: "a4", margin: auto)
  set text(font: "Montserrat", size: 12pt)
  show raw: set text(font: "Martian Mono", weight: "light")

  let date_str = date.display("[month repr:long] [day padding:none], [year]")

  let cover-text = {
    align(center)[
      #text(size: 32pt)[*Tiny Tapeout #shuttle Datasheet*]
      
      #set text(weight: "medium")
      #link(repo-link, text(size: 16pt, raw(repo-link.trim("https://", at: start))))
      
      #v(2.5cm)
      #text(size: 16pt, date_str)
    ]
  }

  // configure stuff for theme
  let selected_theme_colour = colours.THEME_PLUM // default fill
  if theme-override-colour != none {selected_theme_colour = theme-override-colour}
  let qrcode_colour = black
  if qrcode-follows-theme and theme == "bold" {qrcode_colour = selected_theme_colour}

  // make titlepage
  if theme == "classic" {
    image("/resources/logos/tt-logo-colourful.png")
    cover-text

  } else if theme == "bold" {
    set page(fill: selected_theme_colour)

    align(center+horizon)[#image("/resources/logos/tt-logo-white.svg", height: 60%)]

    set text(white)
    cover-text

  } else if theme == "monochrome" {
    align(center+horizon)[#image("/resources/logos/tt-logo-black.svg", height: 60%)]
    cover-text
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

  tiling-logo-page()

  show heading.where(level: 1): this => {
    set text(size: 28pt)
    this
    v(0.1cm)
  }
  show heading.where(level: 2): set text(size: 22pt)
  show heading.where(level: 3): set text(size: 16pt)

  // make table of contents
  set page(footer: _footer(shuttle, invert-text-colour: false, display-pg-as: "i"))
  counter(page).update(1)
  show outline.entry.where(level: 1): this => {
    set block(above: 1em)
    strong(this)
  }

  // can't do direct styling of the title because otherwise the footer freaks out
  outline(
    depth: 2,
    title: heading(level: 1, outlined: false, bookmarked: true)[Table of Contents]
  )
  pagebreak(weak: true)

  context {
    _flip_footer_ordering.update(calc.even(counter(page).get().last()))
  }

  set page(footer: context {_footer(
    shuttle, display-pg-as: "1", flip-ordering: _flip_footer_ordering.final()
  )})

  set par(justify: true)

  if doc != [] {
      pagebreak(weak: true)
      // NOTE: disabled because the odd-even footer flipping stops working properly
      counter(page).update(1)
  }

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

  context {
    let chip_renders = _chip_render_content.final()

    if chip_renders != [] {
      // TODO: need to handle other theme cases
      // and if theme-override-colour is not set

      let qr = none
      let qr_grid = none

      if chip-viewer-link != none {
        qr_grid = annotated-qrcode(
          chip-viewer-link, "online chip viewer",  
          tiaoma-args: ("scale": 2.0, "fg-color": qrcode_colour)
        )
      }


      let sponsor_grid = none
      if _chip_render_sponsor_text.final() != none and _chip_render_sponsor_logo.final() != none {
        sponsor_grid = grid(
          columns: 1,
          rows: 3,
          align: center + horizon,
          row-gutter: 1em,

          _chip_render_sponsor_text.final(),
          _chip_render_sponsor_logo.final(),
          []
        ) 
      }

      let content = none
      let content_arr = ()

      if sponsor_grid != none {
        content_arr.push(sponsor_grid)
      }

      if qr_grid != none {
        content_arr.push(qr_grid)
      }

      if content_arr.len() >= 1 {
        content = grid(
          columns: content_arr.len(),
          rows: 1,
          column-gutter: 1em, row-gutter: 1em,
          align: center + horizon,

          ..content_arr
        )
      }

      if theme == "bold" {
        splash_chapter_page(
          "Chip Renders", 
          page-colour: selected_theme_colour, 
          invert-text-colour: true, 
          footer-text: shuttle, 
          additional-content: content
        )
      } else {
        splash_chapter_page("Chip Renders", invert-text-colour: false, footer-text: shuttle, additional-content: content)
      }
      
      chip_renders
    }
  }

  // make project splash page
  if theme == "bold" {
    splash_chapter_page("Projects", page-colour: selected_theme_colour, invert-text-colour: true, footer-text: shuttle)
  } else {
    splash_chapter_page("Projects", footer-text: shuttle)
  }

  if projects != none {
    projects
  }

  doc

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
  pagebreak(weak: true)


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
  include "../chapters/using-this-datasheet.typ"
  pagebreak(weak: true)

  if theme == "classic" or theme == "monochrome" {
    call-to-action-page()
  } else if theme == "bold" {
    call-to-action-page(page-fill: selected_theme_colour, body-text-colour: white, qrcode-colour: qrcode_colour)
  }
}

#let funding(doc, alt-title: none) = {
  context {
    _funding_content.update(doc)
    _funding_alt_title.update(alt-title)
  }
}

#let renders(sponsor-text: none, sponsor-logo: none, doc) = {
  context {
    _chip_render_content.update(doc)
    _chip_render_sponsor_text.update(sponsor-text)
    _chip_render_sponsor_logo.update(sponsor-logo)
  }
}

#let art(id, rot: 90deg) = {

  let art_manifest = json("/resources/manifest.json").at("art")
  let details = art_manifest.at(id)
  let path_suffix = art_manifest.at("PATH_SUFFIX")

  set text(fill: white, size: 10pt)

  page(
    paper: "a4",
    margin: 0pt,
    footer: none,
  )[
    #align(
      center + horizon,
      
      rotate(rot, 
        reflow: true,
      )[
        #image(
          "/resources/" + path_suffix + details.file,
          height: 100%,
        )
      ]
    )

    #context {
      place(
        bottom + left,
        box(
          fill: colours.ARTWORK_GREY_INFO,
          inset: 4pt,
          width: page.width
        )[
          #if details.title != "" {
            strong(details.title)
          } else {panic("missing title for artwork!")}
          *$dash.em$*
          #if details.designer != "" [
            *Designed by #details.designer.*
          ]
          #if details.artist != "" [
            *Illustrated by #details.artist.*
          ]
        ]
      )
    }
  ]
}

#let get-image-by-id(type, id, ..args) = {
  let manifest = json("/resources/manifest.json")
  let details = none

  // should correspond to keys in /resources/manifest.json
  if type not in ("asset", "art") {
    panic("type of asset not found")
  }

  let path_suffix = manifest.at(type).at("PATH_SUFFIX")

  if id == "" {
    panic("no id given")
  }

  details = manifest.at(type).at(id)
  image("/resources/" + path_suffix + details.file, ..args)
}