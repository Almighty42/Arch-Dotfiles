#!/bin/sh

dotnet new sln -n AspLabKol &&
dotnet new webapi -n Asp.API --framework net8.0 &&
dotnet new classlib -n Asp.DataAccess --framework net8.0 &&
dotnet sln add Asp.API/Asp.API.csproj &&
dotnet add Asp.API/Asp.API.csproj reference Asp.DataAccess/Asp.DataAccess.csproj &&
cd Asp.DataAccess &&
dotnet add package Microsoft.EntityFrameworkCore --version 8.0.0 &&
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0 &&
dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.0 &&
mkdir Models &&
cd ../Asp.API &&
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.0 &&
