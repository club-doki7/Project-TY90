#let en-fonts = ("Libertinus Serif",)
#let zh-fonts = ("Libertinus Serif", "Noto Serif", "Noto Serif CJK SC")
#let monospace-fonts = ("Monaspace Xenon")

#let book-style(body) = {
  set page(numbering: "1", number-align: center)

  set par(spacing: 1.2em)

  set text(lang: "en", font: en-fonts)
  set text(lang: "zh", font: zh-fonts)

  show raw: text.with(
    font: monospace-fonts,
    weight: 350,
    ligatures: false,
    features: (liga: 0,  dlig: 0, clig: 0, calt: 0, locl: 0)
  )
  show raw.where(block: true): set block(breakable: false)
  show math.equation: set text(font: ("Libertinus Math", "Zhuque Fangsong (technical preview)"))
  show math.equation.where(block: true): set block(breakable: false)

  show link: set text(fill: rgb(0, 127, 255))

  show heading.where(level: 1): set align(center)

  body
}

#let term = text.with(font: ("Libertinus Serif", "Zhuque Fangsong (technical preview)"), style: "italic")
#let dt = $. thin$
#let tdt = $thin . thin$