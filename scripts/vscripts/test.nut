// Set up test environment
dofile("tests/fake_env.nut",true);


::Test <- {};

IncludeScript("tests/gsmtest.nut",::Test);
IncludeScript("tests/timertest.nut",::Test);
IncludeScript("tests/utilstest.nut",::Test);
IncludeScript("tests/modulestest.nut",::Test);
