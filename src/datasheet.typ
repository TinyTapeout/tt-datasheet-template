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
  

  // make table of contents
  show outline.entry.where(level: 1): this => {
    set block(above: 1em)
    strong(this)
  }
  outline(title: text(size: 24pt)[Table of Contents #v(1em)])


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