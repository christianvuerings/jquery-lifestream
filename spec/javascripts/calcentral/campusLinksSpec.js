describe('Campus links', function() {

  var json;

  beforeEach(inject(function() {
    jasmine.getJSONFixtures().fixturesPath = 'public/json/';
    jasmine.getFixtures().fixturesPath = 'public';
    json = getJSONFixture('campuslinks.json');

  }));

  it('JSON should be loaded', function() {
    expect(json).toBeDefined();
  });

  it('JSON should have the right properties', function() {
    expect(json.links).toBeDefined();
    expect(json.urlmapping).toBeDefined();
  });

  it('URLs should be valid', function() {
    var urlRegEx = /^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w.,@?\^=%&amp;\:\/~+#\-]*[\w@?\^=%&amp;\/~+#\-])?/;

    for (var i = 0; i < json.links.length; i++) {
      expect(json.links[i].url).toMatch(urlRegEx);
    }
  });

});
