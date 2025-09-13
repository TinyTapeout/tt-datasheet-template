#let project(
  title: "Title", 
  author: "Author", 
  repo-link: "!!! missing repository link !!!", 
  description: [!!! Missing description !!!], 
  address: "0x0000", 
  clock: "No Clock", 
  type: "HDL", 
  
  doc
) = {
  
  // make fake heading - this is the one that gets shown in the table of contents
  // which has the nice address marker next to it
  hide[
    #block(above: 0em, below: 0em)[
        #heading(level: 2)[
            #box(baseline: 0.4em)[
              #rect(fill: rgb(0, 150, 150))[
                #text(white)[*#raw(address)*]
              ]
            ] #title
        ]
      #label(repo-link)
    ]
  ]

  // make read heading and move into position
  // this covers the fake one we just made
  place(
    dy: -26pt,
    heading(level: 2, outlined: false)[#title]
  )
  [by *#author*]

  grid(
    columns: 3,
    column-gutter: 1em,

    // ffc936 good colour
    // NOTE: height retrieved from measure(rectangle), currently hardcoded
    // TODO: encase in context to calculate it all properly
    rect(fill: rgb(0, 150, 150), height: 18.4pt)[#text(white)[*#raw(address)*]],
    rect(fill: rgb("#3e71e7"))[#text(white)[*#clock*]],
    rect(fill: rgb("#db44b2"))[#text(white)[*#type Project*]],
    // rect(fill: rgb("#e63333"))[#text(white)[github.com]]
  )

  show "https://": ""
  link(repo-link)[#raw(repo-link)]

  align(center)[
    "#emph(description)"
  ]

  set heading(offset: 2)

  doc
  pagebreak(weak: true)
}

#let datasheet(
  shuttle: none,
  repo-link: none,
  theme: "classic",

  doc
) = {

  set page(paper: "a4")
  set text(font: "Montserrat", size: 12pt)

  show raw: set text(font: "Martian Mono", weight: "light")

  let date_str = datetime.today().display("[month repr:long] [day padding:none], [year]")

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
    set page(fill: rgb("#9c6fb6"))

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

  doc
}