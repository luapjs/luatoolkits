require("projs/toolex")

function test_str_num()
    print("hello")
    printTable("hello2")
    printTable({"hello2",1,3})
    print(NumEx.nextFloatPos2(1));
    print(NumEx.nextFloatPos(1,5));
    print(string.toStr16( 255,true));
    print(string.toStr16( 255));
    print(string.toColRGB( "ff0aff" ))
    print(string.utf8len("src重工中"))
    print(string.toStrByNum(5,10))
    print(string.upfirst("abdd5,10"))
    print(string.contains("abdd5,dd","abd"))
    local _str = "111,222,333,444,555";
    local _arrs = string.split(_str,",")
    local _arrs2 = string.split(_str,",",true)
    printTable(_arrs,"_arrs")
    printTable(_arrs2,"_arrs2")
    print(string.replace("abdd5,dd","dd","cc"))
    local _val1 = string.toHtml("ab\nd\td5,&dd > 5")
    print(_val1)
    print(string.toHtml(_val1,true))
    for i=1,10 do
        print("int = " ..  NumEx.nextInt(3) .. " .. int0 = " ..  NumEx.nextIntZero(3) .. " .. int1 = " ..  NumEx.nextNum(0,3))
        print(NumEx.nextBool())
    end
    print(math.round(0.2))
    print(math.round(0.51))
    print(math.round(1.51))
    print(math.round(1.5))
    print(math.round(2.9))
    print(NumEx.nextStr(5))
end

function test_tab()
    local src = {"111","222",111,333,222,"666"};
    print(table.lens(src) .. "=,=" ..table.size(src))
    print(table.contains(src,111))
    print(table.contains_func(src,function(item) print(item) return item == 111; end))
    printTable(table.keys(src),"keys")
    printTable(table.values(src),"values")
    printTable(table.removeValues(src,"111"),"111")
    printTable(table.removeValuesFunc(src,function(item) return item == "222";end),"222")
    printTable(table.sub(src,2,4),"src sub")
    printTable(table.sub_page(src,1,2),"page1")
    printTable(table.sub_page(src,2,2),"page2")
    printTable(table.sub_page(src,3,2),"page3")
    printTable(table.merge({1,2,3},src),"merge")
    printTable(src,"src")
    printTable(table.append({1,2,3},src),"append")
    print(table.indexOf(src,"666"),"merge")
    print(table.keyOf(src,"6667"),"keyOf")
    printTable(table.filter(src,function(item) return item ~= 222 end),"filter")
    printTable(table.deepCopy(src,{["1"]=23}),"deepCopy")
    printTable(src,"src")
end

function main()
    -- test_str_num();
    -- test_tab()
end

main()