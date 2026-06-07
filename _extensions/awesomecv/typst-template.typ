#import "@preview/fontawesome:0.6.0": *

//------------------------------------------------------------------------------
// Style
//------------------------------------------------------------------------------

// const color
#let color-darknight = rgb("#131A28")
#let color-darkgray = rgb("#333333")
#let color-middledarkgray = rgb("#414141")
#let color-gray = rgb("#5d5d5d")
#let color-lightgray = rgb("#999999")

// Default style
#let state-font-header = state("font-header", (:))
#let state-font-text = state("font-text", (:))
#let state-color-accent = state("color-accent", color-darknight)
#let state-color-link = state("color-link", color-darknight)

//------------------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------------------

// icon string parser

#let parse_icon_string(icon_string) = {
  if icon_string.starts-with("fa ") [
    #let parts = icon_string.split(" ")
    #if parts.len() == 2 {
      fa-icon(parts.at(1), fill: color-darknight)
    } else if parts.len() == 3 and parts.at(1) == "brands" {
      fa-icon(parts.at(2), font: "Font Awesome 6 Brands", fill: color-darknight)
    } else {
      assert(false, "Invalid fontawesome icon string")
    }
  ] else if icon_string.ends-with(".svg") [
    #box(image(icon_string))
  ] else {
    assert(false, "Invalid icon string")
  }
}

// contaxt text parser
#let unescape_text(text) = {
  // This is not a perfect solution
  text.replace("\\", "").replace(".~", ". ")
}

// layout utility
#let __justify_align(left_body, right_body) = {
  block[
    #box(width: 9fr)[#left_body]
    #box(width: 3fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

#let __justify_align_3(left_body, mid_body, right_body) = {
  block[
    #box(width: 1fr)[
      #align(left)[
        #left_body
      ]
    ]
    #box(width: 1fr)[
      #align(center)[
        #mid_body
      ]
    ]
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

/// Right section for the justified headers
/// - body (content): The body of the right header
#let secondary-right-header(body) = {
  context {
    set text(
      size: 10pt,
      weight: "thin",
      style: "italic",
      fill: state-color-accent.get(),
    )
    body
  }
}

/// Right section of a tertiaty headers.
/// - body (content): The body of the right header
#let tertiary-right-header(body) = {
  set text(
    weight: "light",
    size: 9pt,
    style: "italic",
    fill: color-gray,
  )
  body
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let justified-header(primary, secondary) = {
  set block(
    above: 0.7em,
    below: 0.7em,
  )
  pad[
    #__justify_align[
      #set text(
        size: 12pt,
        weight: "bold",
        fill: color-darkgray,
      )
      #primary
    ][
      #secondary-right-header[#secondary]
    ]
  ]
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right. This is a smaller header compared to the `justified-header`.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let secondary-justified-header(primary, secondary) = {
  __justify_align[
    #set text(
      size: 10pt,
      weight: "regular",
      fill: color-gray,
    )
    #primary
  ][
    #tertiary-right-header[#secondary]
  ]
}

//------------------------------------------------------------------------------
// Header
//------------------------------------------------------------------------------

#let create-header-name(
  firstname: "",
  lastname: "",
) = {
  context {
    pad(bottom: 3pt)[
      #block[
        #set text(
          size: 28pt,
          style: "normal",
          font: state-font-header.get(),
        )
        #text(fill: color-gray, weight: "medium")[#firstname]
        #text(weight: "bold")[#lastname]
      ]
    ]
  }
}

#let create-header-position(
  position: "",
) = {
  set block(
    above: 0.6em,
    below: 0.6em,
  )

  context {
    set text(
      state-color-accent.get(),
      size: 10.5pt,
      weight: "medium",
    )
    position
  }
}

#let create-header-address(
  address: "",
) = {
  set block(
    above: 0.5em,
    below: 0.5em,
  )
  set text(
    color-gray,
    size: 9.5pt,
    style: "italic",
  )

  block[#address]
}

#let create-header-contacts(
  contacts: (),
) = {
  let separator = box(width: 2pt)
  if (contacts.len() > 1) {
    block[
      #set text(
        size: 9pt,
        weight: "regular",
        style: "normal",
      )
      #align(horizon)[
        #for contact in contacts [
          #set box(height: 9pt)
          #box[#parse_icon_string(contact.icon) #link(contact.url)[#contact.text]]
          #separator
        ]
      ]
    ]
  }
}

#let create-header-info(
  firstname: "",
  lastname: "",
  position: "",
  address: "",
  contacts: (),
  align-header: center,
) = {
  align(align-header)[
    #create-header-name(firstname: firstname, lastname: lastname)
    #create-header-position(position: position)
    #create-header-address(address: address)
    #create-header-contacts(contacts: contacts)
  ]
}

#let create-header-image(
  profile-photo: "",
) = {
  if profile-photo.len() > 0 {
    block(
      above: 15pt,
      stroke: none,
      radius: 9999pt,
      clip: true,
      image(
        fit: "contain",
        profile-photo,
      ),
    )
  }
}

#let create-header(
  firstname: "",
  lastname: "",
  position: "",
  address: "",
  contacts: (),
  profile-photo: "",
) = {
  if profile-photo.len() > 0 {
    block[
      #box(width: 5fr)[
        #create-header-info(
          firstname: firstname,
          lastname: lastname,
          position: position,
          address: address,
          contacts: contacts,
          align-header: left,
        )
      ]
      #box(width: 1fr)[
        #create-header-image(profile-photo: profile-photo)
      ]
    ]
  } else {
    create-header-info(
      firstname: firstname,
      lastname: lastname,
      position: position,
      address: address,
      contacts: contacts,
      align-header: center,
    )
  }
}

//------------------------------------------------------------------------------
// Resume Entries
//------------------------------------------------------------------------------

#let resume-item(body) = {
  set text(
    size: 10pt,
    style: "normal",
    weight: "light",
    fill: color-darknight,
  )
  set par(leading: 0.65em)
  set list(indent: 1em)
  // ADJUST VISUAL GAP HIERARCHY HERE
  set block(
    above: 0.75em, // Pulls the bullet list close up against the description line
    below: 1.5em, // Creates a solid, clear gap before the next job/service entry starts
  )
  body
}

#let resume-entry(
  title: none,
  location: "",
  date: "",
  description: "",
  doi: none,       // ADDED: Accepting the new argument
) = {
  pad[
    #justified-header(title, location)

    // Combine Type and DOI into a single inline line
    #let left_column = block[
      #if description != none {
        text(description)
      }
      #if doi != none {
        h(0.3em) // Add clean horizontal breathing room right after the type text
        text(size: 8.5pt, fill: color-gray)[
          #box(height: 8.5pt, baseline: 13.5%)[#image("assets/icon/doi.svg")]
          #link("https://doi.org/" + doi)[#text(fill: rgb("#0066cc"), font: "Liberation Mono")[#doi]]
        ]
      }
    ]

    #secondary-justified-header(left_column, date)
  ]
}

//------------------------------------------------------------------------------
// Resume Template
//------------------------------------------------------------------------------

#let resume(
  title: "CV",
  author: (:),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  profile-photo: "",
  font-header: "Roboto",
  font-text: "Source Sans 3",
  color-accent: rgb("#dc3522"),
  color-link: color-darknight,
  title-meta: none,
  author-meta: none,
  mission-statement: "",
  body,
) = {
  // Set states ----------------------------------------------------------------
  state-font-header.update(font-header)
  state-font-text.update(font-text)
  state-color-accent.update(color-accent)
  state-color-link.update(color-link)

  // Set document metadata -----------------------------------------------------
  set document(
    title: title-meta,
    author: author-meta,
  )

  set text(
    font: (font-text),
    size: 11pt,
    fill: color-darkgray,
    fallback: true,
  )

  set page(
    paper: "a4",
    margin: (left: 12mm, right: 12mm, top: 12.5mm, bottom: 12.5mm),
    footer: context [
      #set text(
        fill: gray,
        size: 8pt,
      )
      #__justify_align_3[
        #smallcaps[#date]
      ][
        #smallcaps[
          #author.firstname
          #author.lastname
          #sym.dot.c
          CV
        ]
      ][
        #counter(page).display()
      ]
    ],
  )

  // set paragraph spacing

  set heading(
    numbering: none,
    outlined: false,
  )

  show heading.where(level: 1): it => [
    #set block(
      above: 1.5em,
      below: 1em,
    )
    
    #set text(
        size: 16pt,
        weight: "regular",
    )

    #context {
      align(left)[
        #text[#strong[#text(state-color-accent.get())[#it.body.text.slice(0, 3)]#text(
            color-darkgray,
          )[#it.body.text.slice(3)]]]
        #box(width: 1fr, line(length: 100%))
      ]
    }
  ]

  show heading.where(level: 2): it => {
    set text(
      color-middledarkgray,
      size: 12pt,
      weight: "thin",
    )
    it.body
  }

  show heading.where(level: 3): it => {
    set text(
      size: 10pt,
      weight: "regular",
      fill: color-gray,
    )
    smallcaps[#it.body]
  }

  // Other settings
  show link: set text(fill: color-link)

  // Contents
  create-header(
    firstname: author.firstname,
    lastname: author.lastname,
    position: author.position,
    address: author.address,
    contacts: author.contacts,
    profile-photo: profile-photo,
  )
  if mission-statement.len() > 0 {
    v(0.5em)
    block(width: 100%)[
      #set text(size: 9pt, style: "italic", fill: color-darkgray)
      #set par(justify: true, leading: 0.55em)
      #mission-statement
    ]
    v(0.5em)
  }
  body
}

