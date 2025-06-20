// based again off https://transring.neocities.org/ring.js :)
// which is based off https://juneish.neocities.org/resources/webstring/
{
  const VALID_WIDGET_TYPES = ["transgender", "nonbinary"]

  let transfemring = {
      // sitelist (oldest to newest)
      // strip the protocol off
      sites: [
          "fem.nz",
          "klara.nz",
          "skyler.lol",
          "transferns.neocities.org",
          "cresentri.com"
      ],
      root: "https://fem.nz"
  }

  transfemring.index = location.href.startsWith("file://") ? 0 : transfemring.sites.findIndex(url => location.href.startsWith("https://" + url));
  let widget = document.currentScript.dataset.widget ?? "transgender";

  function urlWithWidget(path) {
    return `${transfemring.root}/ring/${widget}/${path}`
  }

  if (!VALID_WIDGET_TYPES.includes(widget)) {
    console.log("To web admin: transfem webring widget should have data-widget set to one of the following if configured (attribute will default to 'transgender'):", VALID_WIDGET_TYPES)
    console.log(`data-widget currently set to: ${widget}`)
    widget = "transgender"
  }

  if (transfemring.index === -1) {
    document.currentScript.outerHTML = `
    <div>
      <div class="transfem-ring" style="display: flex; justify-content: center; align-items: center; gap: 3.278%; max-width: 244px; image-rendering: pixelated">
        <a href="${transfemring.root}" target="_top"><img width="132" height="48" src="${urlWithWidget("banner.png")}"></a>
      </div>
      (this site isn't part of the webring... yet!)
    </div>
    `;
  } else {
    let next = "https://" + transfemring.sites[(transfemring.index + 1) % transfemring.sites.length];
    let prev = "https://" + transfemring.sites.at(transfemring.index - 1);
      document.currentScript.outerHTML = `
      <div class="transfem-ring" style="display: flex; justify-content: center; align-items: center; gap: 3.278%; max-width: 244px; image-rendering: pixelated">
        <a href="${prev}" target="_top" style="width: 12.295%">
          <img width="43" height="46" src="${urlWithWidget("arrow.png")}" alt="previous site">
        </a>
        <a href="${transfemring.root}" target="_top" style="width: 68.852%">
          <img width="132" height="48" src="${urlWithWidget("banner.png")}" alt="transfem webring">
        </a>
        <a href="${next}" target="_top" style="width: 12.295%">
          <img width="43" height="46px" src="${urlWithWidget("arrow.png")}" alt="next site" style="transform: scaleX(-1);">
        </a>
      </div>
    `;
  }
}
