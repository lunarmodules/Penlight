utils = require 'pl.utils'
asserteq = require 'pl.test'.asserteq

local echo_lineending = "\n"
local retcode_multiplier = 1
if require 'pl.path'.is_windows then
    echo_lineending = " \n"
else
    if require 'pl.compat'.lua51 then
        retcode_multiplier = 256
    end
end

local function test_executeex(cmd, expected_successful, expected_retcode, expected_stdout, expected_stderr)
    local successful, retcode, stdout, stderr = utils.executeex(cmd)
    asserteq(successful, expected_successful)
    asserteq(retcode,    expected_retcode * retcode_multiplier)
    asserteq(stdout,     expected_stdout)
    asserteq(stderr,     expected_stderr)
end

-- Check the return codes
test_executeex("exit",    true,   0, "", "")
test_executeex("exit 0",  true,   0, "", "")
test_executeex("exit 13", false, 13, "", "")

-- Check output strings
test_executeex("echo stdout",                         true, 0, "stdout" .. echo_lineending, "")
test_executeex("(echo stderr 1>&2)",                  true, 0, "",                          "stderr" .. echo_lineending)
test_executeex("(echo stdout && (echo stderr 1>&2))", true, 0, "stdout" .. echo_lineending, "stderr" .. echo_lineending)
