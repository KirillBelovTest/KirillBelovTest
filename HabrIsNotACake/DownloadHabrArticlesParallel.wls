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


step = 50;


saveResponse = Function[{id, response}, 
    Module[{statusCode, body, file}, 
        statusCode = ToString[response["StatusCode"]];
        body = response["Body"];
        file = FileNameJoin[{$HomeDirectory, "Downloads", "HabrArchive", 
            StringTake[StringTemplate["000000`1`.`2`.html"][id, statusCode], -16]}];
        Export[file, body, "Text"];
    ]
]


Echo[startTime = AbsoluteTime[]]


Module[{tasks, responses},
    Do[
        tasks = Table[
            With[{$id = id, url = articleUrl[id]}, 
                ParallelSubmit[
                    Print["--------------------------"];
                    Print["[", DateString[], "]: ", url];
                    $id -> URLRead[url]
                ]
            ],
            {id, i, i + step - 1}
        ]; 
        
        responses = Association[WaitAll[tasks]];
        KeyValueMap[saveResponse, responses], 
        {i, firstId + 1, firstId + 5000, step}
    ]
];
