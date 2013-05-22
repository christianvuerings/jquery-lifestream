describe('Campus links', function() {

  'use strict';

  var json;

  var isObject = function(obj) {
    return obj === Object(obj);
  };

  beforeEach(inject(function() {
    jasmine.getJSONFixtures().fixturesPath = 'public/json/';
    jasmine.getFixtures().fixturesPath = 'public';
    json = getJSONFixture('campuslinks.json');

  }));

  it('should load the JSON', function() {
    expect(json).toBeDefined();
  });

  it('should have the right JSON properties', function() {
    expect(json.links).toBeDefined();
    expect(json.navigation).toBeDefined();

    for (var i = 0; i < json.links.length; i++) {
      expect(json.links[i].categories).toBeDefined();
      expect(Array.isArray(json.links[i].categories)).toBeTruthy();
      expect(json.links[i].description).toBeDefined();
      expect(json.links[i].name).toBeDefined();
      expect(json.links[i].roles).toBeDefined();
      expect(isObject(json.links[i].roles)).toBeTruthy();
      expect(json.links[i].url).toBeDefined();

      for(var j = 0; j < json.links[i].categories.length; j++) {
        expect(json.links[i].categories[j].topcategory).toBeDefined();
        expect(json.links[i].categories[j].subcategory).toBeDefined();
      }

      expect(json.links[i].roles.faculty).toBeDefined();
      expect(json.links[i].roles.staff).toBeDefined();
      expect(json.links[i].roles.student).toBeDefined();
    }

  });

  it('should check whether the URLs are valid', function() {
    var urlRegEx = /^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w.,@?\^=%&amp;\:\/~+#\-]*[\w@?\^=%&amp;\/~+#\-])?/;

    for (var i = 0; i < json.links.length; i++) {
      expect(json.links[i].url).toMatch(urlRegEx);
    }
  });

  it('should verify that the Top categories from each link are defined in the navigation', function() {

    var topcategories = [];
    for (var i = 0; i < json.navigation.length; i++) {
      for (var j = 0; j < json.navigation[i].categories.length; j++) {
        topcategories.push(json.navigation[i].categories[j].name);
      }
    }

    for (var n = 0; n < json.links.length; n++) {
      for (var o = 0; o < json.links[n].categories.length; o++) {
        var statement = topcategories.indexOf(json.links[n].categories[o].topcategory);
        expect(statement).toBeGreaterThan(-1);
      }
    }

  });

});
