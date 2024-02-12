// https://threejs.org/docs/#examples/en/controls/OrbitControls
// https://github.com/vasturiano/globe.gl/issues/8

const globe_path       = "./CONTENT/main/lightness.png";
const dem_path         = "./CONTENT/main/earth-topology.png";
const sites_path       = "./CONTENT/data/study_sites.csv";
const sites_poly_path  = "./CONTENT/data/study_sites.geojson";
const map_center       = { lat: 40, lng: -65, altitude: 2.5 };
const study_sites      = ([site,species,lat,lng,url,size,color]) => ({ site,species,lat,lng,url,size,color});
const events           = ["click", "touchstart", "mousedown", "wheel"];
const ringsCols        = ["#B38CB4","#B7918C", "#C5A48A"];
const dotColor         = '#05668D';

const world = Globe()
  (document.getElementById('Earth'))
  
  .globeImageUrl(globe_path)
  .bumpImageUrl(dem_path)
  .backgroundColor("#FFFFFF00")
  //.backgroundImageUrl('./CONTENT/main/sky.png')

  .showGraticules(true)
  .showAtmosphere(true)
  .atmosphereAltitude(0.3)


world.controls().autoRotate = true;
world.controls().autoRotateSpeed = 0.6;
world.controls().maxDistance  = 450;
world.controls().minDistance  = 150;
world.pointOfView(map_center);

window.addEventListener("resize", (event) => {

  world.width([event.target.innerWidth]);
  world.height([event.target.innerHeight]);
});

// stop auto-rotate 
for (const event of events) {
  window.addEventListener(event, function () {
    world.controls().autoRotate = false;
  });
}


Promise.all([

  fetch(sites_path).then(res => res.text()).then(d => d3.csvParseRows(d, study_sites)),

]).then(([study_sites]) => {

  world
  
  .ringsData(study_sites)
  .ringMaxRadius(1.5)
  .ringRepeatPeriod(700)
  .ringPropagationSpeed(0.8)
  .ringColor(ringsCols)
  

  .labelsData(study_sites)
  .labelColor(() => dotColor)
  .labelText(d => d.site)
  .labelResolution(10)
  .labelSize(0.2)
  .labelDotRadius(1.5)
  .labelRotation(10)
  .labelsTransitionDuration(0)
  

  .onLabelClick((d) => {
      $.get(d.url + "about.md", function (about_text) {
        bootbox.confirm({
          animate: true,
          size: "large",
          centerVertical: true,
          message: marked.parse(about_text),
          backdrop: true,
          closeButton: false,
          onShow : function(e) {
            $('#intro_start').hide();
            $('#dude').css('opacity', '0.05');
            $('#Earth').css('opacity', '0.05');
          }, 
    
          onHide: function (e) {
            $('#intro_start').show();
            $('#dude').css('opacity', '1');
            $('#Earth').css('opacity', '1');
          },           
          buttons: {
            confirm: {
              label: "More about this ...",
              className: "btn btn-primary btn-sm",
            },
            cancel: {
              label: "Back",
              className: "btn btn-secondary btn-sm",
            },
          },
          callback: function (result) {
            if (result) {
              window.location.href = d.url;
            }
          },
        });
      });

  })


  

});
