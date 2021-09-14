// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

let drake = dragula([document.querySelector('#poker-cards'),
                     document.querySelector('#drop-poker-cards')]);

let Hooks = {}
Hooks.ChooseEstimate = {
  mounted() {
    const hook = this;

    this.handleEvent("estimates_completed", ({ estimates_completed }) => {
      if (estimates_completed) {
        this.flipCards();
      }
    });

    drake.on('drop', function (el, target) {
      if (target.id == 'drop-poker-cards') {
        console.log('pushing new estimate' + el.dataset.card);
        hook.pushEvent("choose-estimate", { card: el.dataset.card }, (reply, ref) => console.log(reply));
      }
    });

  },

  flipCards() {
    var backElements = document.querySelectorAll('.flip-tile-back');
    backElements.forEach((element) => {
      element.style.transform = "rotateY(0deg) rotateX(0deg)";
      element.style.visibility = "visible";
    });
    var frontElements = document.querySelectorAll('.flip-tile-front');
    frontElements.forEach((element) => {
      element.style.transform = 'rotateY(180deg)';
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket