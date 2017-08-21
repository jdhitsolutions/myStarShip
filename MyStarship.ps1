#requires -version 5.0

#demonstrate PowerShell classes in v5

#This is a Non-DSC resource example.

#region Enums

Enum ShipClass {
    Shuttle
    Clipper
    Frigate
    Transport
    XWing
    Cruiser
    Destroyer
    Battlestar
    Dreadnought    
}

Enum ShipSpeed {
    Stopped
    Impulse
    Sublight
    Translight
}

Enum Cloak {
    Absent
    Present
}

#endregion

#region class definition

Class MyStarship {

#region properties
[ValidateNotNullorEmpty()]
[string]$Name 

[ValidateNotNullorEmpty()]
[Shipclass]$ShipClass 

[ValidateNotNullorEmpty()]
[ShipSpeed]$Speed 

[ValidateRange(1,1000)]
[int]$Crew = 1

[boolean]$Shields = $False

[ValidateRange(0,20)]
[int]$Torpedos = 0

[string]$Captain = $env:USERNAME

[Cloak]$CloakingDevice

#These are hidden properties
hidden [string]$Transponder = [guid]::NewGuid().Guid
hidden [datetime]$ManufacturingDate = (Get-Date).Addyears(245)

#endregion

#region methods

#returns the new crew complement
[int]AddCrew([int]$Number) {
    $this.Crew+= $Number
    return $this.Crew
}

[timespan]GetAge() {
    $timespan = (Get-Date).Addyears(250) - $this.ManufacturingDate
    return $timespan
}

[string]GetAge([switch]$AsString) {
    $timespan = (Get-Date).Addyears(250) - $this.ManufacturingDate
    return $timespan.ToString()
}

#return True or False if operation was successful
[Boolean]RaiseShields() {
 if (-Not $this.shields) {
    $this.shields = $True
    #must use Return keyword
    Return $True
 }
 else {
    Write-Warning "Are you paying attention Captain $($this.captain)? The shields are already up."
    Return $False
 }

} #close RaiseShields method

[Boolean]LowerShields() {
 if ($this.shields) {
    $this.shields = $False
    Return $True
 }
 else {
    Write-Warning "Are you paying attention Captain $($this.captain)? The shields are already down."
    Return $False
 }

} #close RaiseShields method

[void]OpenCommunication () {

    1..7 | foreach {
    $f = Get-Random -Minimum 500 -Maximum 1200
    $d = Get-Random -Minimum 90 -Maximum 125
    [console]::Beep($f,$d)
    }

} #close OpenCommunication

#region using overloads

[void]Fire() {
 if ($this.Torpedos -gt 0 ) {
     Write-Host "Fire!" -ForegroundColor Red -BackgroundColor Yellow
     $this.Torpedos-=1
 }
 else {
    Write-Warning "There's nothing left to fire."
 }

} #close first Fire method

[void]Fire([int]$Count) {
    1..$count | foreach  {
     if ($this.Torpedos -ge $_) {
         Write-Host "Fire $_ !" -ForegroundColor Red -BackgroundColor Yellow
         $this.Torpedos-=1
         Start-Sleep -Milliseconds 200
     }
     else {
        Write-Warning "There's nothing left to fire."
        #bail out
        Break
     }
    }
} #close second Fire method

#endregion

#endregion

#region constructor

#I have 2 ways of constructing an instance of this class
MyStarship() {}

MyStarShip([string]$Name,[ShipClass]$ShipClass) {

    $this.name = $Name
    $this.ShipClass = $ShipClass
    $this.Speed = "Stopped"

    Switch ($ShipClass) {
    "Battlestar"  { 
                    $this.CloakingDevice = [Cloak]::Present
                    $this.Torpedos = 20 
                    $this.Crew = 1000
                    }
    "Destroyer"   { 
                    $this.CloakingDevice = [Cloak]::Present
                    $this.Torpedos = 18 
                    $this.crew = 600
                    
                    }
    "Dreadnought" { 
                    $this.CloakingDevice = [Cloak]::Present
                    $this.Torpedos = 20
                    $this.crew = 900
                   }
    "Cruiser" { 
                $this.Torpedos = 10
                $this.crew = 200
                 }
    "Clipper" { 
                $this.Torpedos = 5
                $this.crew = 100
               }
    } #switch

}
#endregion

} #close MyStarship

#endregion

RETURN

#region fun with the class

[MyStarship]::New.OverLoadDefinitions

#this will use all defaults
[MyStarship]::New()

$ship = [MyStarship]::New("FSS Snover","Dreadnought")

#or use New-Object
New-Object MyStarship "Galactica","Battlestar"

$ship

#cannot create read-only properties
$ship | Get-Member

$ship.Crew = 10
$ship
#or use method
$ship.AddCrew(900)

$ship.Speed = [shipspeed]::Sublight

$ship.RaiseShields()
#raise them again
$ship.RaiseShields()

$ship.Torpedos = 100
$ship.fire.OverloadDefinitions
$ship.fire()

$ship.fire(3)

$ship.Torpedos
$ship.fire(20)

$ship.OpenCommunication()

#hidden properties
$ship | get-member -MemberType Properties

#property is there if you know it
$ship.transponder

#you can use it in a method
$ship.GetAge()
$ship.GetAge($True)

#or build a function around the method
Function Get-StarshipAge {
[cmdletbinding()]
Param([mystarship]$Ship)

Write-Verbose "Getting the age of $($Ship.name)"

$ship | Select Name,ManufacturingDate,
@{Name="Age";Expression = {$_.GetAge()}}

}

Get-StarshipAge $ship -Verbose

#hidden properties can be serialized with Export-CliXML


#endregion

<#
Your homework:

Add methods to enagage and disengage cloak if it is present
Fill out rest of Switch to define defaults for different ship classes
Create functions around methods and properties

#>