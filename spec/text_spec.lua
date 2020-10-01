local text = require("pl.text")

describe("pl.text.Template", function ()

  it("replaces placeholders", function ()
    local tempalte = text.Template("${here} is the $answer")
    local out = tempalte:substitute({ here = 'one', answer = 'two' })
    assert.is.equal('one is the two', out)
  end)

end)
