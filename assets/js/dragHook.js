export default (drake) => class DragHook {
  constructor(){
    console.log( "Factory");
  }
  mounted() {
    console.log('element mounted ');
    const hook = this;

    drake.on('drop', function (el, target) {
      if (target.id == 'drop-poker-cards') {
        console.log('pushing new estimate' + el.dataset.card);
        hook.pushEvent("choose-estimate", {card: el.dataset.card}, (reply, ref) => console.log(reply));
      }
    });  
  }
}