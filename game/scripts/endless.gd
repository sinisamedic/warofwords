extends RefCounted
## Run rules are independent of campaign progression and rewards.
const REGULAR := [1,2,4,5,6,8,9,10,12,13,14,16,17,18,20,21,22]
const BOSSES := [3,7,11,15,19,23]
static func opponent(wave: int) -> int:
	return BOSSES[((wave/5)-1)%BOSSES.size()] if wave%5==0 else REGULAR[(wave-1-wave/5)%REGULAR.size()]
static func health(wave: int) -> int:
	return 85+wave*15+int(pow(float(wave),1.35)*3)+(65+wave*7 if wave%5==0 else 0)
static func damage(wave: int) -> int:
	return 12+wave+(5 if wave%5==0 else 0)
static func interval(wave: int) -> float:
	return maxf(5.5,12.0-wave*.22)
static func word_score(tiles: int) -> int:
	return tiles*10+maxi(0,tiles-4)*15
static func key(language: String, adjacent: bool) -> String:
	return language+("_adjacent" if adjacent else "_any")
static func valid_meta(b: Dictionary) -> bool:
	var continues=b.get("continues",0)
	if not (continues is int or continues is float) or not is_finite(float(continues)) or float(int(continues))!=float(continues) or continues<0 or continues>3: return false
	if not b.get("continue_pending",false) is bool: return false
	if b.get("continue_pending",false) and (continues>=3 or b.get("checkpoint",false)): return false
	for k in ["wave","score","run_words","run_seconds"]:
		if not (b.get(k) is int or b.get(k) is float) or not is_finite(float(b[k])) or b[k]<0: return false
	for k in ["wave","score","run_words"]:
		if float(int(b[k]))!=float(b[k]): return false
	return b.wave>=1 and b.wave<=100000 and b.get("checkpoint",false) is bool and b.get("mode")=="endless" and int(b.get("mission",-1))==opponent(int(b.wave))
