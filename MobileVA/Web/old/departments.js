/**
 * Created by yiding on 2014/9/5.
 */
var school={
    "SSCI":0,
    "SHSS":1,
    "SENG":2,
    "SBM":3
};
var dept ={
    "LIFS":0,
    "CHEM":0,
    "MATH":0,
    "PHYS":0,
    "HUMA":1,
    "SOSC":1,
    "CBME":2,
    "CIVL":2,
    "CSE":2,
    "ECE":2,
    "IELM":2,
    "MAE":2,
    "ACCT":3,
    "ECON":3,
    "FINA":3,
    "ISOM":3,
    "MARK":3,
    "MGMT":3,
    "CSEMATH":null,
    "CBMEMAE":null
};

var deptNames =[
    "LIFS",
    "CHEM",
    "MATH",
    "PHYS",
    "HUMA",
    "SOSC",
    "CBME",
    "CIVL",
    "CSE",
    "ECE",
    "IELM",
    "MAE",
    "ACCT",
    "ECON",
    "FINA",
    "ISOM",
    "MARK",
    "MGMT",
    "CSEMATH",
    "CBMEMAE"
];

var deptIndex ={
    "LIFS":0,
    "CHEM":1,
    "MATH":2,
    "PHYS":3,
    "HUMA":4,
    "SOSC":5,
    "CBME":6,
    "CIVL":7,
    "CSE":8,
    "ECE":9,
    "IELM":10,
    "MAE":11,
    "ACCT":12,
    "ECON":13,
    "FINA":14,
    "ISOM":15,
    "MARK":16,
    "MGMT":17,
    "CSEMATH":18,
    "CBMEMAE":19

};

var deptIndexS ={
    "LIFS":0,
    "CHEM":1,
    "MATH":2,
    "PHYS":3,
    "HUMA":0,
    "SOSC":1,
    "CBME":0,
    "CIVL":1,
    "CSE":2,
    "ECE":3,
    "IELM":4,
    "MAE":5,
    "ACCT":0,
    "ECON":1,
    "FINA":2,
    "ISOM":3,
    "MARK":4,
    "MGMT":5,
    "CSEMATH":null,
    "CBMEMAE":null
};


var schoolList= ["SSCI","SHSS","SENG","SBM"];
var schoolOffset = [0, 4, 6, 12, 18];
function getSchoolName(departmentName){
    return schoolList[dept[departmentName]];
}

function getSchoolIndex(departmentName) {
    return dept[departmentName];
}