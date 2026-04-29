#!/usr/bin/env wolframscript

articleUrl = StringTemplate["https://habr.com/ru/articles/`1`/"];


getLastId[] := 
With[{
    content = URLRead["https://habr.com/ru/feed/"]["Body"]
}, 
    Max[StringCases[content, Shortest["<article id=\"" ~~ id__ ~~ "\""] :> ToExpression[id]]]
];


lastId = getLastId[];


Echo[lastId, "LastID"];


getFirstId[] := 
Module[{
    habrArchive = FileNameJoin[{$HomeDirectory, "Downloads", "HabrArchive"}], 
    fileNames
}, 
    If[Not[FileExistsQ[habrArchive]], CreateDirectory[habrArchive]];

    fileNames = FileNames["*", {habrArchive}];

    If[Length[fileNames] > 0, 
        Max @ Map[ToExpression[First[StringSplit[#, "."]]]&] @ Map[FileNameTake] @ fileNames, 
        0
    ]
];


firstId = getFirstId[];


Echo[firstId, "FirstID"];

Module[{url, response, body, statusCode, file, 
    habrArchive = FileNameJoin[{$HomeDirectory, "Downloads", "HabrArchive"}]
},
    Do[
        Pause[RandomReal[{0.15, 0.45}]];
        url = articleUrl[id];
        response = URLRead[url];
        statusCode = response["StatusCode"];
        body = response["Body"];
        file = FileNameJoin[{habrArchive, StringTake[StringTemplate["000000`1`.`2`.html"][id, statusCode], -16]}];
        Export[file, body, "Text"];
        Echo[StringTemplate["`1` => `2`"][url, file], "Downloaded"];, 

        {id, firstId + 1, firstId + 1000, 1}
    ]
];
