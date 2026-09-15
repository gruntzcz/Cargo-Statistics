class CargoStatsInfo extends GSInfo
{
    function GetAuthor()       { return "GruntzCZ"; }
    function GetName()         { return "Cargo Statistics"; }
    function GetDescription()  { return "Tracks the total amount of cargo transported by your company and displays statistics for each cargo type in the Story Book."; }
    function GetVersion()      { return 1; }
    function GetDate()         { return "2026-09-15"; }
    function CreateInstance()  { return "CargoStats"; }
    function GetShortName()    { return "CSTS"; }
    function GetAPIVersion()   { return "1.10"; }
    function GetUrl()          { return ""; }
}

RegisterGS(CargoStatsInfo());