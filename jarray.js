// @author: JerryPan<https://github.com/panii/jarray> ‎2013‎.‎3
// @description: My javascript arrays vs erlang lists serializing and deserializing util library.
// @usage: JArray.stringify(["AAA", "BBB", ["CCC", "DDD"]]) // result: "2#AAA||BBB||1#CCC|DDD"
// @usage: JArray.parse("2#AAA||BBB||1#CCC|DDD") // result: ["AAA", "BBB", ["CCC", "DDD"]]
export class JArray {
	static _tokens = ['','|','||','|||','||||','|||||','||||||','|||||||',
	'||||||||','|||||||||','||||||||||','|||||||||||','||||||||||||',
	'|||||||||||||','||||||||||||||','|||||||||||||||','||||||||||||||||',
	'|||||||||||||||||','||||||||||||||||||'];
	static _at = '#';

    // usage: JArray.stringify(["my array"])
	static stringify(A, maxDeep = 0) {
		if(!A || A.length == 0) return "1" + JArray._at;
		if(!maxDeep) {
			var deepArr = [1];
			JArray._getMaxDeep(A, deepArr, 1);
			maxDeep = deepArr.length;
		}
		return JArray._stringify(A, maxDeep, 0);
	}

    // usage: JArray.parse("1#my array")
	static parse(S) {
		if(S.length == 0) return [];
		var pos = S.indexOf(JArray._at);
		var deep = S.substr(0, pos);
		var R = [S];
		JArray._parse(R, deep);
		return R[0];
	}

	static _stringify(A, maxDeep, i) {
		return (maxDeep - i) + JArray._at + A.map(function(a) {
			if(Array.isArray(a)) {
				return JArray._stringify(a, maxDeep, i + 1);
			}
			return a;
		}).join(JArray._getToken(maxDeep - i));
	}

	static _getMaxDeep(A, deepArr, currentDeep) {
		A.every(function(a) {
			if(Array.isArray(a)) {
				deepArr[currentDeep] = currentDeep + 1;
				JArray._getMaxDeep(a, deepArr, deepArr[currentDeep]);
			}
			return true;
		});
	}

	static _parse(A, deep) {
		if(deep > 0) {
			for(var i = 0, l = A.length; i < l; i++) {
				var pos = A[i].indexOf(JArray._at);
				if(pos > -1) {
					var deep = A[i].substr(0, pos);
					var s = A[i].substr(pos + 1);
                    if (s.length == 0) {
                        A[i] = [];
                    } else {
                        A[i] = s.split(JArray._getToken(deep));
                    }
					JArray._parse(A[i], deep - 1);
				}
				else {
					// var d = parseFloat(A[i]);
					// if(d) A[i] = d;
				}
			}
		}
		else {
			for(var i = 0, l = A.length; i < l; i++) {
				// var d = parseFloat(A[i]);
				// if(d) A[i] = d;
			}
		}
	}

	static _getToken(l) {
		return JArray._tokens[l];
	}
}

function j_stringify_test() {
	JArray_TEST.j_stringify_test();
}

function j_parse_test() {
	JArray_TEST.j_parse_test();
}

var JArray_TEST = {
	testsArr : [
		[
			"case A", 1,
			["哈哈","呵呵"],
			"1#哈哈|呵呵"
		],
		[
			"case B", 2,
			["哈哈",["嘻","嘻"],"呵呵"],
			"2#哈哈||1#嘻|嘻||呵呵"
		],
		[
			"case C", 2,
			["哈哈",["嘻","嘻"],"呵呵",["嘻","嘻"]],
			"2#哈哈||1#嘻|嘻||呵呵||1#嘻|嘻"
		],
		[
			"case D", 3,
			["哈哈",["嘻","嘻"],"呵呵",["嘻","嘻"],["HO",["HO","HO"]]],
			"3#哈哈|||2#嘻||嘻|||呵呵|||2#嘻||嘻|||2#HO||1#HO|HO"
		],
		[
			"case E", 5,
			["笔记本",["鱼","剑",["鱼","剑",["鱼","剑",["鱼","剑"]]]],"28",["戴尔","N",["A","B"]],["鱼","678",["A","B"]]],
			"5#笔记本|||||4#鱼||||剑||||3#鱼|||剑|||2#鱼||剑||1#鱼|剑|||||28|||||4#戴尔||||N||||3#A|||B|||||4#鱼||||678||||3#A|||B"
		],
		[
			"case F", 5,
			[["鱼","666",["A","B"]],"笔记本",["鱼","剑",["鱼","剑",["鱼","剑",["鱼","剑"]]]],"28",["戴尔","N",["A","B"]]],
			"5#4#鱼||||666||||3#A|||B|||||笔记本|||||4#鱼||||剑||||3#鱼|||剑|||2#鱼||剑||1#鱼|剑|||||28|||||4#戴尔||||N||||3#A|||B"
		],
		[
			"case G", 8,
			["A",["A",["A",["A",["A",["A",["A",["A","B"],"B"],"B"],"B"],"B"],"B"],"B"],"B"],
			"8#A||||||||7#A|||||||6#A||||||5#A|||||4#A||||3#A|||2#A||1#A|B||B|||B||||B|||||B||||||B|||||||B||||||||B"
		],
		[
			"case H", 1,
			["A"],
			"1#A"
		],
		[
			"case I", 2,
			["A",["B"]],
			"2#A||1#B"
		],
		[
			"case J", 1,
			["丰","26","male","zone.com","javascript,php,css,html,actionscript,erlang,python,ruby"],
			"1#丰|26|male|zone.com|javascript,php,css,html,actionscript,erlang,python,ruby"
		],
		[
			"case K", 1,
			["1","2","3","4","5","漂亮"],
			"1#1|2|3|4|5|漂亮"
		],
		[
			"case L", 2,
			[["1","2"],["3","4"]],
			"2#1#1|2||1#3|4"
		],
		[
			"case M", 2,
			[["1","2"],["3","4"]],
			"2#1#1|2||1#3|4"
		],
		[
			"case N", 2,
			[["1.1234", "false"],["null", "undefined"]],
			"2#1#1.1234|false||1#null|undefined"
		]
	],

	j_stringify_test: function()
	{
		var tests = JArray_TEST.testsArr;
		tests.every(function(a) {
			JArray_TEST.test_echo(a[0], JArray.stringify(a[2]), a[3], {ori:a[2]});
			return true;
		});
		tests.every(function(a) {
			JArray_TEST.test_echo(a[0], JArray.stringify(a[2], a[1]), a[3], {ori:a[2]});
			return true;
		});
		return 'test finish!';
	},

	j_parse_test : function()
	{
		var tests = JArray_TEST.testsArr;
		tests.every(function(a) {
			JArray_TEST.test_echo(a[0], JSON.stringify(JArray.parse(a[3])), JSON.stringify(a[2]));
			return true;
		});
		return 'test finish!';
	},

	test_echo : function(label, got, expect, others) {
		var res = ((got === expect)?'pass':'not-pass');

		if(res == 'not-pass') {
			console.log(label + ' - ' + res);
			console.log('got');
			console.log(got);
			console.log('expect');
			console.log(expect);
			console.log('');
		}
		else {
			if(others && others.ori)
				console.log(label + ' - ' + res + ', json length:' + JSON.stringify(others.ori).length + ', JArray length:'+expect.length)// + ' ' + JSON.stringify(others.ori));
			else
				console.log(label + ' - ' + res);
		}
	}
}
