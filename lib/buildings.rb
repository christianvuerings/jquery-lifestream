class Buildings

  def self.get(building_name)
    name = building_name.upcase
    bldg = self.buildings[name]
    if bldg.nil?
      # try again stripping off what might be a room number from the front of the string
      name = name.gsub(/^\d*/, "").strip
      bldg = self.buildings[name]
      unless bldg.nil?
        room_number = building_name.match(/^\d*/)[0]
        bldg = bldg.merge({"room_number" => room_number})
      end
    end
    bldg
  end

  private

  def self.buildings

    # Building data sourced from BearFacts and
    # http://registrar.berkeley.edu/Default.aspx?PageID=bldgabb.html
    # TEMPxx buildings at end of hash are known campus locations with good coords
    # but no official db entries, to be integrated in future if useful.
    @buildings ||= {
      "2224 PIEDMNT" => {
        "display" => "2224 Piedmont",
        "lat" => "37.871296",
        "lon" => "-122.25278"
      },
      "2232 PIEDMNT" => {
        "display" => "2232 Piedmont",
        "lat" => "37.871135",
        "lon" => "-122.252737"
      },
      "2240 PIEDMNT" => {
        "display" => "2240 Piedmont",
        "lat" => "37.870983",
        "lon" => "-122.252694"
      },
      "2515CHANNING" => {
        "display" => "2515 Channing",
        "lat" => "37.867409",
        "lon" => "-122.258284"
      },
      "BANCROFT" => {
        "display" => "Bancroft Studio (2401 Bancroft)",
        "lat" => "37.868662",
        "lon" => "-122.261202"
      },
      "BANCROFT LIB" => {
        "display" => "Bancroft Library",
        "lat" => "37.872272",
        "lon" => "-122.258773"
      },
      "BARKER" => {
        "display" => "Barker Hall",
        "lat" => "37.873950000000001",
        "lon" => "-122.26549"
      },
      "BARROWS" => {
        "display" => "Barrows Hall",
        "lat" => "37.870060000000002",
        "lon" => "-122.25791"
      },
      "BECHTEL" => {
        "display" => "Bechtel Engineering Center",
        "lat" => "37.874040000000001",
        "lon" => "-122.25836"
      },
      "BECHTEL AUD" => {
        "display" => "Bechtel Auditorium",
        "lat" => "37.874625",
        "lon" => "-122.258091"
      },
      "BERK ART MUS" => {
        "display" => "Berkeley Art Museum",
        "lat" => "37.86871000000001",
        "lon" => "-122.255667"
      },
      "BIRGE" => {
        "display" => "Birge Hall",
        "lat" => "37.872190000000003",
        "lon" => "-122.25724"
      },
      "BLUM" => {
        "display" => "Blum Hall",
        "lat" => "37.874954",
        "lon" => "-122.259143"
      },
      "BOALT" => {
        "display" => "Boalt Hall, School of Law",
        "lat" => "37.86992",
        "lon" => "-122.25341"
      },
      "BOT GARDEN" => {
        "display" => "Botanical Garden Conference Center",
        "lat" => "37.87579",
        "lon" => "-122.238654"
      },
      "CALIFORNIA" => {
        "display" => "California Hall",
        "lat" => "37.87189",
        "lon" => "-122.26038"
      },
      "CALVIN LAB" => {
        "display" => "Calvin Lab",
        "lat" => "37.870989999999999",
        "lon" => "-122.25393"
      },
      "CAMPBELL" => {
        "display" => "Campbell Hall",
        "lat" => "37.872979999999998",
        "lon" => "-122.25705000000001"
      },
      "CAMPBELL ANX" => {
        "display" => "Campbell Annex",
        "lat" => "",
        "lon" => ""
      },
      "CHANNING CTS" => {
        "display" => "Channing Courts (Ellsworth Street)",
        "lat" => "37.866367",
        "lon" => "-122.262447"
      },
      "CHAVEZ" => {
        "display" => "Caesar E. Chavez Student Center",
        "lat" => "37.86974",
        "lon" => "-122.26017"
      },
      "CHEIT" => {
        "display" => "Cheit Hall",
        "lat" => "37.871644",
        "lon" => "-122.253574"
      },
      "CORY" => {
        "display" => "Cory Hall",
        "lat" => "37.875050000000002",
        "lon" => "-122.25752"
      },
      "DAVIS" => {
        "display" => "Davis Hall",
        "lat" => "37.874519999999997",
        "lon" => "-122.25829"
      },
      "DOE LIBRARY" => {
        "display" => "Doe Library",
        "lat" => "37.872439999999997",
        "lon" => "-122.25955999999999"
      },
      "DONNER LAB" => {
        "display" => "Donner Laboratory",
        "lat" => "37.87463",
        "lon" => "-122.25649"
      },
      "DURANT" => {
        "display" => "Durant Hall",
        "lat" => "37.871259999999999",
        "lon" => "-122.26013"
      },
      "DURHAM THTRE" => {
        "display" => "Durham Studio Theater (Dwinelle)",
        "lat" => "37.870579999999997",
        "lon" => "-122.26040999999999"
      },
      "DWINELLE" => {
        "display" => "Dwinelle Hall",
        "lat" => "37.870579999999997",
        "lon" => "-122.26040999999999"
      },
      "DWINELLE AN" => {
        "display" => "Dwinelle Annex",
        "lat" => "37.870350000000002",
        "lon" => "-122.26123"
      },
      "ESHLEMAN" => {
        "display" => "Eshleman Hall",
        "lat" => "37.868795",
        "lon" => "-122.260104"
      },
      "ETCHEVERRY" => {
        "display" => "Etcheverry Hall",
        "lat" => "37.875700000000002",
        "lon" => "-122.25924000000001"
      },
      "EVANS" => {
        "display" => "Evans Hall",
        "lat" => "37.873629999999999",
        "lon" => "-122.25783"
      },
      "FACULTY CLUB" => {
        "display" => "The Faculty Club",
        "lat" => "37.872194",
        "lon" => "-122.255838"
      },
      "FOOTHILL" => {
        "display" => "Foothill Student Housing",
        "lat" => "37.875429",
        "lon" => "-122.255763"
      },
      "FOOTHILL 1" => {
        "display" => "Foothill Residential Complex Building 1",
        "lat" => "",
        "lon" => ""
      },
      "FOOTHILL 4" => {
        "display" => "Foothill Residential Complex Building 4",
        "lat" => "",
        "lon" => ""
      },
      "GARDNERSTACK" => {
        "display" => "David Gardner Stacks (Doe Library)",
        "lat" => "37.872439999999997",
        "lon" => "-122.25955999999999"
      },
      "GIANNINI" => {
        "display" => "Giannini Hall",
        "lat" => "37.873570000000001",
        "lon" => "-122.26233999999999"
      },
      "GIAUQUE" => {
        "display" => "William F. Giauque Hall",
        "lat" => "",
        "lon" => ""
      },
      "GILMAN" => {
        "display" => "Gilman Hall",
        "lat" => "37.87265",
        "lon" => "-122.25629000000001"
      },
      "GPB" => {
        "display" => "Genetics & Plant Biology Building",
        "lat" => "37.873429999999999",
        "lon" => "-122.26473"
      },
      "GSPP" => {
        "display" => "Goldman School of Public Policy",
        "lat" => "37.876014",
        "lon" => "-122.257866"
      },
      "HAAS" => {
        "display" => "Haas School of Business",
        "lat" => "37.871690000000001",
        "lon" => "-122.25384"
      },
      "HAAS PAVIL" => {
        "display" => "Haas Pavilion",
        "lat" => "37.870246",
        "lon" => "-122.262039"
      },
      "HANDBALL CTS" => {
        "display" => "Handball Courts (RSF)",
        "lat" => "",
        "lon" => ""
      },
      "HARGROVE LIB" => {
        "display" => "Hargrove Music Library",
        "lat" => "37.870440000000002",
        "lon" => "-122.2561"
      },
      "HAVILAND" => {
        "display" => "Haviland Hall",
        "lat" => "37.873739999999998",
        "lon" => "-122.26105"
      },
      "HEARST ANNEX" => {
        "display" => "Hearst Field Annex",
        "lat" => "37.86947",
        "lon" => "-122.25817000000001"
      },
      "HEARST EPOOL" => {
        "display" => "Hearst East Pool",
        "lat" => "37.86947",
        "lon" => "-122.25817000000001"
      },
      "HEARST GYM" => {
        "display" => "Hearst Gym",
        "lat" => "37.86956",
        "lon" => "-122.25687000000001"
      },
      "HEARSTGYMCTS" => {
        "display" => "Hearst Gym Tennis Courts",
        "lat" => "",
        "lon" => ""
      },
      "HEARST MIN" => {
        "display" => "Hearst Memorial Mining Building",
        "lat" => "37.874459999999999",
        "lon" => "-122.25727000000001"
      },
      "HEARST POOL" => {
        "display" => "Hearst Pool",
        "lat" => "37.86956",
        "lon" => "-122.25687000000001"
      },
      "HEARSTMUSEUM" => {
        "display" => "Hearst Museum of Anthropology",
        "lat" => "37.869125",
        "lon" => "-122.256971"
      },
      "HERTZ" => {
        "display" => "Hertz Concert Hall",
        "lat" => "37.871099999999998",
        "lon" => "-122.25566999999999"
      },
      "HESSE" => {
        "display" => "Hesse Hall",
        "lat" => "37.874319999999997",
        "lon" => "-122.25936"
      },
      "HILDEBRAND" => {
        "display" => "Hildebrand Hall",
        "lat" => "37.872610000000002",
        "lon" => "-122.2557"
      },
      "HILGARD" => {
        "display" => "Hilgard Hall",
        "lat" => "37.873164",
        "lon" => "-122.263405"
      },
      "INTN'L HOUSE" => {
        "display" => "International House",
        "lat" => "37.869750000000003",
        "lon" => "-122.25145000000001"
      },
      "KERR CAMPUS" => {
        "display" => "Clark Kerr Campus Building 1",
        "lat" => "37.864326",
        "lon" => "-122.248851"
      },
      "KOSHLAND" => {
        "display" => "Koshland Hall",
        "lat" => "37.873939999999997",
        "lon" => "-122.26487"
      },
      "KROEBER" => {
        "display" => "Kroeber Hall",
        "lat" => "37.869880000000002",
        "lon" => "-122.2552"
      },
      "LATIMER" => {
        "display" => "Latimer Hall",
        "lat" => "37.873130000000003",
        "lon" => "-122.25592"
      },
      "LECONTE" => {
        "display" => "LeConte Hall",
        "lat" => "37.872489999999999",
        "lon" => "-122.25688"
      },
      "LEWIS" => {
        "display" => "Lewis Hall",
        "lat" => "37.873060000000002",
        "lon" => "-122.25521999999999"
      },
      "LHS" => {
        "display" => "Lawrence Hall of Science",
        "lat" => "37.87926000000003",
        "lon" => "-122.246677"
      },
      "LI KA SHING" => {
        "display" => "Li Ka Shing Center",
        "lat" => "37.873464",
        "lon" => "-122.26539"
      },
      "LSA" => {
        "display" => "Life Sciences Addition",
        "lat" => "37.871400000000001",
        "lon" => "-122.26324"
      },
      "MCCONE" => {
        "display" => "McCone Hall",
        "lat" => "37.874110000000002",
        "lon" => "-122.25964999999999"
      },
      "MCENERNEY" => {
        "display" => "McEnerney Hall (1750 Arch St)",
        "lat" => "37.87653999999999",
        "lon" => "-122.26468"
      },
      "MCLAUGHLIN" => {
        "display" => "McLaughlin Hall",
        "lat" => "37.873829",
        "lon" => "-122.259051"
      },
      "MEMORIAL STD" => {
        "display" => "Memorial Stadium",
        "lat" => "37.870706000000002",
        "lon" => "-122.25049700000001"
      },
      "MINOR" => {
        "display" => "Minor Hall",
        "lat" => "37.871319999999997",
        "lon" => "-122.255"
      },
      "MINOR ADDITN" => {
        "display" => "Minor Hall Addition",
        "lat" => "37.871406",
        "lon" => "-122.255119"
      },
      "MLK ST UNION" => {
        "display" => "Martin Luther King Jr. Student Union",
        "lat" => "37.869137",
        "lon" => "-122.259614"
      },
      "MOFFITT" => {
        "display" => "Moffitt Library",
        "lat" => "37.872549999999997",
        "lon" => "-122.26081000000001"
      },
      "MORGAN" => {
        "display" => "Morgan Hall",
        "lat" => "37.87332",
        "lon" => "-122.26425"
      },
      "MORRISON" => {
        "display" => "Morrison Hall",
        "lat" => "37.870869999999996",
        "lon" => "-122.25644"
      },
      "MOSES" => {
        "display" => "Moses Hall",
        "lat" => "37.870989999999999",
        "lon" => "-122.25799000000001"
      },
      "MULFORD" => {
        "display" => "Mulford Hall",
        "lat" => "37.872639999999997",
        "lon" => "-122.26449"
      },
      "NO FACILITY" => {
        "display" => "No facility",
        "lat" => false,
        "lon" => false
      },
      "NORTH GATE" => {
        "display" => "North Gate Hall",
        "lat" => "37.874870000000001",
        "lon" => "-122.25984"
      },
      "OBRIEN" => {
        "display" => "OBrien Hall",
        "lat" => "37.874400000000001",
        "lon" => "-122.25906000000001"
      },
      "OFF CAMPUS" => {
        "display" => "Off campus",
        "lat" => false,
        "lon" => false
      },
      "PAC FILM ARC" => {
        "display" => "Pacific Film Archive Theater",
        "lat" => "37.869036",
        "lon" => "-122.257529"
      },
      "PAULEY" => {
        "display" => "Pauley Ballroom (ASUC)",
        "lat" => "37.869315",
        "lon" => "-122.256868"
      },
      "PB GREENHOUS" => {
        "display" => "Plant and Microbial Biology Greenhouse",
        "lat" => "",
        "lon" => ""
      },
      "PIMENTEL" => {
        "display" => "Pimental Hall",
        "lat" => "37.87341",
        "lon" => "-122.25602000000001"
      },
      "PLAYHOUSE" => {
        "display" => "Zellerbach Playhouse",
        "lat" => "37.869427",
        "lon" => "-122.261322"
      },
      "RAQBALL CTS" => {
        "display" => "Racquetball Courts (RSF)",
        "lat" => "",
        "lon" => ""
      },
      "REC SPRT FAC" => {
        "display" => "Recreational Sports Facility",
        "lat" => "37.868549999999999",
        "lon" => "-122.26276"
      },
      "RFS 112" => {
        "display" => "Richmond Field Station 112",
        "lat" => "37.91854",
        "lon" => "-122.329845"
      },
      "RSF FLDHOUSE" => {
        "display" => "RSF Field House",
        "lat" => "37.86923",
        "lon" => "-122.262211"
      },
      "SODA" => {
        "display" => "Soda Hall",
        "lat" => "37.87567",
        "lon" => "-122.25870999999999"
      },
      "SOUTH ANNEX" => {
        "display" => "South Annex",
        "lat" => "",
        "lon" => ""
      },
      "SOUTH HALL" => {
        "display" => "South Hall",
        "lat" => "37.87133",
        "lon" => "-122.25851"
      },
      "SPIEKER POOL" => {
        "display" => "Spieker Aquatics Complex ",
        "lat" => "37.868911",
        "lon" => "-122.261998"
      },
      "SPROUL" => {
        "display" => "Sproul Hall",
        "lat" => "37.869599999999998",
        "lon" => "-122.25878"
      },
      "SQUASH CTS" => {
        "display" => "Squash Courts (RSF)",
        "lat" => "",
        "lon" => ""
      },
      "STANLEY" => {
        "display" => "Stanley Hall",
        "lat" => "37.874020000000002",
        "lon" => "-122.25613"
      },
      "STARR LIB" => {
        "display" => "Starr East Asian Library",
        "lat" => "37.873570000000001",
        "lon" => "-122.26034"
      },
      "STEPHENS" => {
        "display" => "Stephens Hall",
        "lat" => "37.87124",
        "lon" => "-122.25761"
      },
      "SUTARDJA DAI" => {
        "display" => "Sutardja Dai Hall",
        "lat" => "37.875079",
        "lon" => "-122.258264"
      },
      "TAN" => {
        "display" => "Tan Hall",
        "lat" => "37.873100000000001",
        "lon" => "-122.25642000000001"
      },
      "TANG CENTER" => {
        "display" => "Tang Center, University Health Services",
        "lat" => "37.867835000000002",
        "lon" => "-122.263843"
      },
      "TOLMAN" => {
        "display" => "Tolman Hall",
        "lat" => "37.874110000000002",
        "lon" => "-122.26392"
      },
      "UCB ART MUSE" => {
        "display" => "Berkeley Art Museum",
        "lat" => "37.86871000000001",
        "lon" => "-122.255667"
      },
      "UNIT I CHNY" => {
        "display" => "Unit 1 Residence Hall - Cheney",
        "lat" => "37.868086",
        "lon" => "-122.255602"
      },
      "UNIT I CHRST" => {
        "display" => "Unit 1 Residence Hall - Christian",
        "lat" => "37.868171",
        "lon" => "-122.255044"
      },
      "UNIT I CNTRL" => {
        "display" => "Residence Hall Unit I Central",
        "lat" => "37.867638",
        "lon" => "-122.254347"
      },
      "UNIT II CNTRL" => {
        "display" => "Residence Hall Unit II Central",
        "lat" => "",
        "lon" => ""
      },
      "UNIT I SLOTT" => {
        "display" => "Unit 1 Residence Hall - Slottman",
        "lat" => "37.867544",
        "lon" => "-122.255237"
      },
      "UNIT II TOWL" => {
        "display" => "Unit 2 Residence Hall - Towle",
        "lat" => "37.866452",
        "lon" => "-122.254679"
      },
      "UNIT II WADA" => {
        "display" => "Unit 2 Residence Hall - Wada",
        "lat" => "37.865783",
        "lon" => "-122.254862"
      },
      "UNIT III DIN" => {
        "display" => "Residence Hall Unit III Dining",
        "lat" => "37.867807",
        "lon" => "-122.260365"
      },
      "UNIV HALL" => {
        "display" => "University Hall",
        "lat" => "37.87189",
        "lon" => "-122.26635"
      },
      "VALLEY LSB" => {
        "display" => "Valley Life Sciences Building",
        "lat" => "37.871479999999998",
        "lon" => "-122.26211000000001"
      },
      "WARREN" => {
        "display" => "Warren Hall",
        "lat" => "37.874562",
        "lon" => "-122.266911"
      },
      "WELLMAN" => {
        "display" => "Wellman Hall",
        "lat" => "37.873096",
        "lon" => "-122.262779"
      },
      "WHEELER" => {
        "display" => "Wheeler Hall",
        "lat" => "37.871290000000002",
        "lon" => "-122.25914"
      },
      "WHEELER AUD" => {
        "display" => "Wheeler Auditorium",
        "lat" => "37.871290000000002",
        "lon" => "-122.25914"
      },
      "WURSTER" => {
        "display" => "Wurster Hall",
        "lat" => "37.8705",
        "lon" => "-122.25488"
      },
      "ZELLERBACH" => {
        "display" => "Zellerbach Hall",
        "lat" => "37.869109999999999",
        "lon" => "-122.26078"
      },
      "TEMP0" => {
        "display" => "Afro House",
        "lat" => "37.868391",
        "lon" => "-122.249916"
      },
      "TEMP1" => {
        "display" => "Alumni House",
        "lat" => "37.869655",
        "lon" => "-122.261096"
      },
      "TEMP101" => {
        "display" => "Northside Co-op Apartments",
        "lat" => "37.876801",
        "lon" => "-122.259657"
      },
      "TEMP103" => {
        "display" => "Oscar Wilde House",
        "lat" => "37.867417",
        "lon" => "-122.250988"
      },
      "TEMP106" => {
        "display" => "Public Affairs",
        "lat" => "37.867410000000001",
        "lon" => "-122.265581"
      },
      "TEMP108" => {
        "display" => "Residential & Student Services Bldg.",
        "lat" => "37.866884",
        "lon" => "-122.255849"
      },
      "TEMP109" => {
        "display" => "Ridge House",
        "lat" => "37.87592",
        "lon" => "-122.261331"
      },
      "TEMP110" => {
        "display" => "Rochdale Apartments",
        "lat" => "37.865503",
        "lon" => "-122.259593"
      },
      "TEMP111" => {
        "display" => "Sather Gate",
        "lat" => "37.870294",
        "lon" => "-122.259615"
      },
      "TEMP112" => {
        "display" => "Senior Hall",
        "lat" => "37.871946",
        "lon" => "-122.255533"
      },
      "TEMP113" => {
        "display" => "Sherman Hall",
        "lat" => "37.869755",
        "lon" => "-122.250581"
      },
      "TEMP114" => {
        "display" => "Simon Hall",
        "lat" => "37.86985",
        "lon" => "-122.25266000000001"
      },
      "TEMP117" => {
        "display" => "South Hall Annex",
        "lat" => "37.871499999999997",
        "lon" => "-122.25857000000001"
      },
      "TEMP122" => {
        "display" => "Stebbins Hall",
        "lat" => "37.876462",
        "lon" => "-122.259271"
      },
      "TEMP124" => {
        "display" => "Stern Hall",
        "lat" => "37.875066",
        "lon" => "-122.255614"
      },
      "TEMP13" => {
        "display" => "Berkeley Wireless Research Center",
        "lat" => "37.869442",
        "lon" => "-122.267296"
      },
      "TEMP131" => {
        "display" => "Unit 1 Residence Hall - Deutsch",
        "lat" => "37.867621",
        "lon" => "-122.255709"
      },
      "TEMP132" => {
        "display" => "Unit 1 Residence Hall - Freeborn",
        "lat" => "37.86818",
        "lon" => "-122.254647"
      },
      "TEMP133" => {
        "display" => "Unit 1 Residence Hall - Putnam",
        "lat" => "37.867663",
        "lon" => "-122.254668"
      },
      "TEMP135" => {
        "display" => "Unit 2 Residence Hall - Cunningham",
        "lat" => "37.866359",
        "lon" => "-122.255259"
      },
      "TEMP136" => {
        "display" => "Unit 2 Residence Hall - Davidson",
        "lat" => "37.866418",
        "lon" => "-122.254282"
      },
      "TEMP137" => {
        "display" => "Unit 2 Residence Hall - Ehrman",
        "lat" => "37.86585",
        "lon" => "-122.255344"
      },
      "TEMP138" => {
        "display" => "Unit 2 Residence Hall - Griffiths",
        "lat" => "37.86591",
        "lon" => "-122.254196"
      },
      "TEMP141" => {
        "display" => "Unit 3 Residence Hall - Ida Sproul",
        "lat" => "37.867011",
        "lon" => "-122.260945"
      },
      "TEMP142" => {
        "display" => "Unit 3 Residence Hall - Norton",
        "lat" => "37.867426",
        "lon" => "-122.260805"
      },
      "TEMP143" => {
        "display" => "Unit 3 Residence Hall - Priestly",
        "lat" => "37.866994",
        "lon" => "-122.259947"
      },
      "TEMP144" => {
        "display" => "Unit 3 Residence Hall - Spens-Black",
        "lat" => "37.867477",
        "lon" => "-122.259958"
      },
      "TEMP146" => {
        "display" => "University House",
        "lat" => "37.874363",
        "lon" => "-122.262485"
      },
      "TEMP147" => {
        "display" => "University Press (2120 Berkeley Way)",
        "lat" => "37.873092",
        "lon" => "-122.267672"
      },
      "TEMP153" => {
        "display" => "Wolf House",
        "lat" => "37.868332",
        "lon" => "-122.252834"
      },
      "TEMP154" => {
        "display" => "Womens Faculty Club",
        "lat" => "37.872027",
        "lon" => "-122.254878"
      },
      "TEMP18" => {
        "display" => "Bowles Hall",
        "lat" => "37.873357",
        "lon" => "-122.253168"
      },
      "TEMP2" => {
        "display" => "Andres Castro Arms",
        "lat" => "37.868671",
        "lon" => "-122.250044"
      },
      "TEMP21" => {
        "display" => "Campanile (Sather Tower)",
        "lat" => "37.872332",
        "lon" => "-122.257964"
      },
      "TEMP23" => {
        "display" => "Casa Zimbabwe",
        "lat" => "37.875954",
        "lon" => "-122.261202"
      },
      "TEMP24" => {
        "display" => "Center for Latin American Studies",
        "lat" => "37.869281",
        "lon" => "-122.255816"
      },
      "TEMP26" => {
        "display" => "Child Development Center",
        "lat" => "37.865613",
        "lon" => "-122.262211"
      },
      "TEMP27" => {
        "display" => "Clark Kerr Campus Center",
        "lat" => "37.863576",
        "lon" => "-122.24983"
      },
      "TEMP28" => {
        "display" => "Cleary Hall",
        "lat" => "37.866692",
        "lon" => "-122.25982"
      },
      "TEMP29" => {
        "display" => "Cloyne Court Co-op",
        "lat" => "37.876149",
        "lon" => "-122.257994"
      },
      "TEMP3" => {
        "display" => "Anthony Hall",
        "lat" => "37.870690000000003",
        "lon" => "-122.25819"
      },
      "TEMP30" => {
        "display" => "CNMAT (1750 Arch St.)",
        "lat" => "37.876606",
        "lon" => "-122.26455"
      },
      "TEMP31" => {
        "display" => "The Convent",
        "lat" => "37.868146",
        "lon" => "-122.27854"
      },
      "TEMP34" => {
        "display" => "Davis House",
        "lat" => "37.869535",
        "lon" => "-122.250581"
      },
      "TEMP35" => {
        "display" => "Doe Addition",
        "lat" => "37.872312999999998",
        "lon" => "-122.258821"
      },
      "TEMP4" => {
        "display" => "Architects & Engineers (A&E)",
        "lat" => "37.870162",
        "lon" => "-122.258756"
      },
      "TEMP42" => {
        "display" => "Edwards Track Stadium",
        "lat" => "37.869613999999997",
        "lon" => "-122.26479399999999"
      },
      "TEMP45" => {
        "display" => "Euclid Hall",
        "lat" => "37.876547",
        "lon" => "-122.260065"
      },
      "TEMP47" => {
        "display" => "Faculty Club",
        "lat" => "37.871916",
        "lon" => "-122.255876"
      },
      "TEMP48" => {
        "display" => "Fenwick Weavers Village",
        "lat" => "37.864961",
        "lon" => "-122.260365"
      },
      "TEMP5" => {
        "display" => "Athletic Ticket Office",
        "lat" => "37.868756",
        "lon" => "-122.265869"
      },
      "TEMP50" => {
        "display" => "Fox Cottage (2350 Bowditch St.)",
        "lat" => "37.86788",
        "lon" => "-122.256771"
      },
      "TEMP54" => {
        "display" => "Girton Hall",
        "lat" => "37.87239",
        "lon" => "-122.254165"
      },
      "TEMP55" => {
        "display" => "Goldman School of Public Policy",
        "lat" => "37.875638",
        "lon" => "-122.25785"
      },
      "TEMP57" => {
        "display" => "Haas Pavilion",
        "lat" => "37.869399999999999",
        "lon" => "-122.26222"
      },
      "TEMP69" => {
        "display" => "Hillegass-Parker House",
        "lat" => "37.863775",
        "lon" => "-122.256246"
      },
      "TEMP70" => {
        "display" => "Hoyt Hall",
        "lat" => "37.876378",
        "lon" => "-122.259743"
      },
      "TEMP71" => {
        "display" => "Ida L. Jackson Graduate House",
        "lat" => "37.868103",
        "lon" => "-122.254186"
      },
      "TEMP72" => {
        "display" => "Institute for Research on Labor and Employment",
        "lat" => "37.867215999999999",
        "lon" => "-122.25838"
      },
      "TEMP74" => {
        "display" => "Ishi Court (Dwinelle Hall)",
        "lat" => "37.870579999999997",
        "lon" => "-122.26040999999999"
      },
      "TEMP75" => {
        "display" => "Kidd Hall",
        "lat" => "37.876835",
        "lon" => "-122.259314"
      },
      "TEMP76" => {
        "display" => "Kingman Hall",
        "lat" => "37.877089",
        "lon" => "-122.257404"
      },
      "TEMP8" => {
        "display" => "Banway Building (2111 Bancroft Way)",
        "lat" => "37.86788",
        "lon" => "-122.26687"
      },
      "TEMP86" => {
        "display" => "Lothlorien Hall",
        "lat" => "37.867858",
        "lon" => "-122.249594"
      },
      "TEMP87" => {
        "display" => "Manville Hall",
        "lat" => "37.865639",
        "lon" => "-122.267039"
      },
      "TEMP99" => {
        "display" => "Naval Architecture Building",
        "lat" => "37.875088",
        "lon" => "-122.258741"
      }
    }
  end

end
