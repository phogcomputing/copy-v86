
var eth;

window["user_script"] = function(str) { 
  console.log("user_script arg: "+str);

  switch (true) {
    case /Account Generated a/.test(str):
	console.log("Account Generated");
	account=str.split(" ")[4];
        eth = prompt("Please fund this deployment account in order to cover the gas fees.", account);
        if (eth != null) {
	  console.log("Requested funding fo account: "+eth);
        }
	phrase = document.getElementById("filesystem_get_file");
	if (phrase) {
	  phrase.value = "/scaffold-eth/packages/hardhat/mnemonic.txt\r";
          window["emulator"]("printf '[mnemonic] ' >/dev/ttyS0\n");
	  window["emulator"]("cat /scaffold-eth/packages/hardhat/mnemonic.txt >/dev/ttyS0\n");
	  //window["emulator"]("cd /scaffold-eth && yarn account >/dev/ttyS0\n");
	  window["emulator"]("yarn --network ropsten balance " + account + " >/dev/ttyS0\n");
        }
	break;
    case /computer.rentals:2015/.test(str):
	var iframe = document.createElement('iframe');
	iframe.src = "http://localhost:3000" /* str */;
	iframe.style = "background: #000000; background-position: center; background-repeat: no-repeat; background-image:url(https://coin.computer/img/Spin-1s-200px.gif); position: absolute; top: 100px; left: 10px; width:100%; height: 400px; border:none; margin:0; padding:0; overflow:hidden;";
	document.body.appendChild(iframe);
	window["emulator"]("kill -9 630;cd /scaffold-eth && yarn generate >/dev/ttyS0\n");
	break;
    case /ETH/.test(str):
	balance=str.split(" ")[0].trim();
	//alert("Balance: ["+balance+"]");
        if (balance === "0.0") {
          prompt("Please fund this deployment account in order to cover the gas fees.", eth);
	  window["emulator"]("yarn --network ropsten balance " + account + " >/dev/ttyS0\n");
	} else {
	  window["emulator"]("cd /scaffold-eth && yarn deploy >/dev/ttyS0\n");
	}
	break;
  }

};


