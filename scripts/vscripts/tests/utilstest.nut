::BestLocation <- {};

p("=================");
p("Utils Test");
p("=================");
IncludeScript("complite/utils.nut",::BestLocation);

p("Loaded Utils Library");


function TestKeyReset(KeyReset)
{
	print("Testing KeyReset with null key...");
	
	local T = { }
	local k = "mykey"
	
	local kr = KeyReset(T, k);
	assert(!(k in T));
	
	kr.set("Yay!");
	assert(k in T);
	assert(T[k] == "Yay!");

	kr.unset();
	assert(!(k in T));
	p("Passed.");

	
	print("Testing KeyReset with used key...");

	T[k] <- 3;

	kr = KeyReset(T, k);
	kr.set(5.0);
	assert(k in T);
	assert(T[k] == 5.0);

	kr.unset();
	assert(k in T);
	assert(T[k] == 3);

	p("Passed.");

	print("Testing KeyReset Misc cases...");

	T[k] = 599;
	kr = KeyReset(T, k)
	assert(k in T);
	assert(T[k] == 599);

	kr.set(4);
	assert(k in T);
	assert(T[k] == 4);
	kr.set(6);
	assert(k in T);
	assert(T[k] == 6);

	kr.unset();
	assert(k in T);
	assert(T[k] == 599);
	kr.unset();
	assert(k in T);
	assert(T[k] == 599);

	kr.set("nice");
	assert(k in T);
	assert(T[k] == "nice");
	
	kr.unset();
	assert(k in T);
	assert(T[k] == 599);

	p("Passed.");
}


TestKeyReset(::BestLocation.Utils.KeyReset);