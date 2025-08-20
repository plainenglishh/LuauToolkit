--[=[
    Library for testing VM conformance.
    ]=]
local vm_conformance = {};

local testing = require("@self/testing");
vm_conformance.run_test = testing.run_test;
vm_conformance.run_tests = testing.run_tests;

local test_cases = require("@self/test_cases");
vm_conformance.test_cases = test_cases;

return vm_conformance;
