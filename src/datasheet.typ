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
  
// #heading(level: 2)[
//     #box(baseline: 0.3em)[
//       #rect(fill: rgb(0, 150, 150))[
//         #text(white)[`0x0000`]
//       ]
//     ] Chip ROM
// ]

  grid(
    columns: (auto, 20%),
    column-gutter: 1em,

    heading(level: 2)[#title],
    box(baseline: 1em)[by #author]
  )

  grid(
    columns: 3,
    column-gutter: 1em,

    // ffc936 good colour
    rect(fill: rgb(0, 150, 150))[#text(white)[#address]],
    rect(fill: rgb("#3e71e7"))[#text(white)[#clock]],
    rect(fill: rgb("#db44b2"))[#text(white)[#type Project]],
    // rect(fill: rgb("#e63333"))[#text(white)[github.com]]
  )

  show "https://": ""
  link(repo-link)[#raw(repo-link)]

  align(center)[
    "#emph(description)"
  ]

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
      #datetime.today().display("[month repr:long] [day padding:none], [year]")
    ]
  }
  

  show heading.where(level: 1): set text(size: 24pt)
  show heading.where(level: 2): set text(size: 20pt)
  show heading.where(level: 3): set text(size: 18pt)

  // make table of contents
  show outline.entry.where(level: 1): this => {
    set block(above: 1em)
    strong(this)
  }
  outline(depth: 2, title: text(size: 24pt)[Table of Contents #v(1em)])


  counter(page).update(0)

  if doc != [] {
      pagebreak()
  }

  set page(
    footer: {
      set text(size: 10pt)
      align(right)[
        #box()[
          // get the title of the current chapter
          #let title = context query(selector(heading.where(level: 1)).before(here())).last().body
          #emph(title)
          #h(0.5cm)
          #context strong(counter(page).display("1"))
        ]
      ]
    }
  )

  doc
}