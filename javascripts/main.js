$(function(){
 $('dl.result > dt').click(function(){
  console.log(1)
  var dt = $(this);
  dt.next('dd').toggleClass('active')
 })
})
