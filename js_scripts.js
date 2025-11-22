import { ethers } from "https://esm.sh/ethers@6.13.2";
import { CID } from "https://esm.sh/multiformats@12.1.3";

const staticData = [
    {"inputs":[{"internalType":"address","name":"subject","type":"address"},{"internalType":"bytes32","name":"docHash","type":"bytes32"},{"internalType":"string","name":"uri","type":"string"},{"internalType":"uint64","name":"expiresAt","type":"uint64"}],"name":"issueCredential","outputs":[{"internalType":"uint256","name":"credId","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"internalType":"uint256","name":"credId","type":"uint256"}],"name":"revokeCredential","outputs":[],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"internalType":"uint256","name":"credId","type":"uint256"}],"name":"getCredential","outputs":[{"components":[{"internalType":"bytes32","name":"docHash","type":"bytes32"},{"internalType":"string","name":"uri","type":"string"},{"internalType":"address","name":"issuer","type":"address"},{"internalType":"address","name":"subject","type":"address"},{"internalType":"uint64","name":"issuedAt","type":"uint64"},{"internalType":"uint64","name":"expiresAt","type":"uint64"},{"internalType":"uint256","name":"issuerSeqIndex","type":"uint256"}],"internalType":"struct Credential","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},
    {"inputs":[{"internalType":"uint256","name":"credId","type":"uint256"}],"name":"isRevoked","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},
    {"inputs":[{"internalType":"uint256","name":"credId","type":"uint256"},{"internalType":"bytes32","name":"providedDocHash","type":"bytes32"}],"name":"verifyCredential","outputs":[{"internalType":"bool","name":"isValid","type":"bool"},{"internalType":"string","name":"reason","type":"string"}],"stateMutability":"view","type":"function"},
    {"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"credId","type":"uint256"},{"indexed":true,"internalType":"address","name":"issuer","type":"address"},{"indexed":true,"internalType":"address","name":"subject","type":"address"},{"indexed":false,"internalType":"bytes32","name":"docHash","type":"bytes32"},{"indexed":false,"internalType":"string","name":"uri","type":"string"},{"indexed":false,"internalType":"uint256","name":"issuerSeqIndex","type":"uint256"},{"indexed":false,"internalType":"uint64","name":"expiresAt","type":"uint64"}],"name":"CredentialIssued","type":"event"}
];

var counterOfValues = 0

const $ = (sel) => document.querySelector(sel);
const u = (id, v) => (document.getElementById(id).textContent = v);
const link = (id, href, text) => {
    const a = document.getElementById(id); a.href = href; a.textContent = text;
}; const outputOnScreen = (id, v) => (document.getElementById(id).textContent = v);

let listOfdata = [];

window.addEventListener('eip6963:announceProvider', (event) => {
    const detailsOfEvent = event?.detail;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
    if (detailsOfEvent && detailsOfEvent.provider && !listOfdata.find(d => d.info.uuid === detailsOfEvent.info.uuid)) {
    listOfdata.push(detailsOfEvent);
    }
});

window.dispatchEvent(new Event('eip6963:requestProvider'));

function getTheProviderOfTheEtherum() {
    
    const dataOfProviderInList = listOfdata.find(d => /metamask/i.test(d.info.rdns || d.info.name || ''));
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    if (dataOfProviderInList?.provider) return dataOfProviderInList.provider;

    if (listOfdata[0]?.provider) return listOfdata[0].provider;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    const ethereumVar = window.ethereum;
    if (!ethereumVar) return null;
    if (Array.isArray(ethereumVar.providers) && ethereumVar.providers.length) {
    const isItMetaMaskOrNot = ethereumVar.providers.find(p => p.isMetaMask);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    return isItMetaMaskOrNot || ethereumVar.providers[0];
    }
    return ethereumVar;
}

let theOneWhoProvides, theOneWhoSings, accountOfMetaMask, chainIdOfTheTask;
let blockchnContrct;

async function connectTometamaskserver() {
    try {
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    const eth = getTheProviderOfTheEtherum();
    if (!eth) {
        const installUrl = 'https://metamask.io/download/';
        const msg = `EVM wallet not found. Install it : ${installUrl}`;
        console.warn(msg);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        outputOnScreen('issueStatus', msg);
        return;
    }
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    theOneWhoProvides = new ethers.BrowserProvider(eth);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    const accts = await theOneWhoProvides.send('eth_requestAccounts', []);
    accountOfMetaMask = accts[0];
    theOneWhoSings = await theOneWhoProvides.getSigner();
    const networkResponse = await theOneWhoProvides.getNetwork();
    chainIdOfTheTask = Number(networkResponse.chainId);
    $("#inpIssuer").value = accountOfMetaMask;
    $("#inpChain").value = `${networkResponse.name || 'chain'} (${chainIdOfTheTask})`;

    const valueOfTheInputContract = $("#inpContract").value.trim();
    if (valueOfTheInputContract) blockchnContrct = new ethers.Contract(valueOfTheInputContract, staticData, theOneWhoSings);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    console.log("Connected :: ", accountOfMetaMask, "via: ", eth?.isMetaMask ? 'MetaMask: ' : (eth?.isCoinbaseWallet ? 'Coinbase Wallet ::' : 'EVM Wallet ::  '));
    } catch (err) {
    console.error(err);
    alert("connection failed : : " + (err?.message || err));
    }
}


async function convertTo256BytesValue(buf) {
    const digest = await crypto.subtle.digest("SHA-256", buf);
    return new Uint8Array(digest);
}
function areTwoBitesEqualToEachOther(a, b) { if (a.length !== b.length) return false; for (let i=0;i<a.length;i++) if (a[i]!==b[i]) return false; return true; }


async function sendFileToPinata(file, jwt) {
    const url = "https://api.pinata.cloud/pinning/pinFileToIPFS";
    const fd = new FormData();
    fd.append("file", file, file.name);
    const metadata = { name: file.name, keyvalues: { project: "univault" } };
    fd.append("pinataMetadata", JSON.stringify(metadata));
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    const res = await fetch(url, { method: "POST", headers: { Authorization: `Bearer ${jwt}` }, body: fd });
    if (!res.ok) throw new Error(`Pinata upload failed: ${res.status} ${await res.text()}`);
    return await res.json();
}


let bytesOfFile=null, lastFile256Sha=null, bytesOfKec=null, cidId=null, CidOfKey=null;


document.addEventListener("DOMContentLoaded", () => {

    $("#btnConnect")?.addEventListener("click", connectTometamaskserver);

    $("#btnUpload")?.addEventListener("click", async () => {
    try {

if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        const uploadedFile = $("#issueFile").files[0];
        const accessTokenOfPonata = $("#inpPinataJWT").value.trim();
        if (!uploadedFile) return alert("Fike not provided");
        if (!accessTokenOfPonata) return alert("JWT Token not provided for pinata");

        const buf = await uploadedFile.arrayBuffer();
        bytesOfFile = new Uint8Array(buf);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        lastFile256Sha = await convertTo256BytesValue(buf);
        bytesOfKec = ethers.keccak256(bytesOfFile);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        outputOnScreen("issueStatus","Uploading to Pinata...");
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        const { IpfsHash } = await sendFileToPinata(uploadedFile, accessTokenOfPonata);
        cidId = IpfsHash;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        const gatewayUrl = `https://gateway.pinata.cloud/ipfs/${IpfsHash}`;
        u("cidOut", IpfsHash);
        link("cidLink", gatewayUrl, gatewayUrl);
        u("kecBytes", bytesOfKec);
        CidOfKey = ethers.keccak256(ethers.toUtf8Bytes(cidId));
        u("kecCid", CidOfKey);

if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        let intialShaValueText = "N/A";
        try {
        const cidOfhash = CID.parse(IpfsHash);
        const metaHash = cidOfhash.multihash;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        if (metaHash.code !== 0x12) intialShaValueText = `Unexpected multihash code ${metaHash.code} (expected 0x12 for sha2-256)`;
        else {
            const arrayOfDigestOfCidId = new Uint8Array(metaHash.digest);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

            intialShaValueText = areTwoBitesEqualToEachOther(arrayOfDigestOfCidId, lastFile256Sha) ? "matches" : "mismatch";
        }
        } catch (e) { intialShaValueText = "CID parse failed: " + (e?.message || e); }
        $("#shaCheck").innerHTML = intialShaValueText.includes("✔︎") ? `<span class="ok">${intialShaValueText}</span>` : `<span class="bad">${intialShaValueText}</span>`;

        outputOnScreen("issueStatus", " succesfully Uploaded. Hash shared up.");
        $("#btnIssue").disabled = false;
    } catch (err) {
        console.error(err);
        outputOnScreen("issueStatus", `Error :: ${err.message || err}`);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

    }
    });


    $("#btnIssue")?.addEventListener("click", async () => {
    try {
        if (!blockchnContrct) {
        const contactctValueProvided = $("#inpContract").value.trim();
        if (!contactctValueProvided) return alert("Contract address required");
        if (!theOneWhoSings) return alert("First we need Connect wallet .");
        blockchnContrct = new ethers.Contract(contactctValueProvided, staticData, theOneWhoSings);
        }
        const subject = $("#issueSubject").value.trim();
        if (!ethers.isAddress(subject)) return alert(" subject address is not a valid one ");
        if (!cidId || !bytesOfFile) return alert("file uploading is required as first step");

        const valueOfExpiryDate = $("#issueExpiry").value;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        let expiresAt = 0n;
        if (valueOfExpiryDate) {
        const t = Math.floor(new Date(valueOfExpiryDate).getTime()/1000);
        if (!Number.isFinite(t) || t<=0) return alert("Provided date of expiry is invalid. ");
        expiresAt = BigInt(t);
        }

        const strategyOfHash = $("#issueHashStrategy").value;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        const hashOfTheDoc = strategyOfHash === "cid" ? CidOfKey : bytesOfKec;

        outputOnScreen("issueStatus", "Sending transaction...");
        const theTransaction = await blockchnContrct.issueCredential(subject, hashOfTheDoc, `ipfs://${cidId}`, expiresAt);
        const transactionAfterWaiting = await theTransaction.wait();


        let idAssignedForIssuer = null;
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        for (const log of transactionAfterWaiting.logs) {
        try {
            const parsed = blockchnContrct.interface.parseLog(log);
            if (parsed?.name === "CredentialIssued") { idAssignedForIssuer = parsed.args.credId?.toString(); break; }
        } catch {}
        }
        outputOnScreen("issueStatus", ` Issued. Tx: ${transactionAfterWaiting.hash}\nCred ID: ${idAssignedForIssuer ?? "(parse failed)"}\nURI: ipfs://${cidId}\nHash used: ${hashOfTheDoc}`);
    } catch (err) {
        console.error(err);
        outputOnScreen("issueStatus", `Error: ${err.message || err}`);
    }
    });


    $("#btnRead")?.addEventListener("click", async () => {
    try {
        if (!blockchnContrct) {
        const caddr = $("#inpContract").value.trim();
        if (!caddr) return alert("Please provide contract address inside the Setup ");
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
        blockchnContrct = new ethers.Contract(caddr, staticData, theOneWhoSings || theOneWhoProvides);
        }
        const credId = $("#credId").value.trim();
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

        if (!credId) return alert("Enter a credential ID.");
        const c = await blockchnContrct.getCredential(credId);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
        const wasItRevoked = await blockchnContrct.isRevoked(credId);
        const outputStuff = [
        `docHash: ${c.docHash}`, `uri: ${c.uri}`, `issuer: ${c.issuer}`,
        `subject: ${c.subject}`, `issuedAt: ${c.issuedAt?.toString?.()}`,
        `expiresAt: ${c.expiresAt?.toString?.()}`, `issuerSeqIndex: ${c.issuerSeqIndex?.toString?.()}`,
        `revoked: ${wasItRevoked}`
        ];
        outputOnScreen("readStatus", outputStuff.join("\n"));
    } catch (err) {
        console.error(err);
        outputOnScreen("readStatus", `Error : ${err.message || err}`);
    }
    });


    $("#btnRevoke")?.addEventListener("click", async () => {
    try {
        if (!blockchnContrct) {
        const valueOfTheProvidedContract = $("#inpContract").value.trim();
        if (!valueOfTheProvidedContract) return alert("contract address is required  in the Setup  ");
        if (!theOneWhoSings) return alert("Connect wallet first.");
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }

            if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
        blockchnContrct = new ethers.Contract(valueOfTheProvidedContract, staticData, theOneWhoSings);
        }
        const credId = $("#credId").value.trim();
        if (!credId) return alert("Enter a credential ID.");
        outputOnScreen("readStatus", "Sending revoke tx...");
        const transactionofRevokingCredentails = await blockchnContrct.revokeCredential(credId);
        const rcpt = await transactionofRevokingCredentails.wait();
        outputOnScreen("readStatus", ` succesfully Revoked the transaction  : ${rcpt.hash}`);
    } catch (err) {
        console.error(err);
        outputOnScreen("readStatus", `Error : ${err.message || err}`);
    }
    });


    $("#btnVerify")?.addEventListener("click", async () => {
    try {
        if (!blockchnContrct) {
        const caddr = $("#inpContract").value.trim();
        if (!caddr) return alert(" contract address is needed in the Setup above ");
        blockchnContrct = new ethers.Contract(caddr, staticData, theOneWhoSings || theOneWhoProvides);
        }
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
        const ifOftheCred = $("#credId").value.trim();
        if (!ifOftheCred) return alert("Enter a credential ID to verify.");
        const verifyingTheFile = $("#verifyFile").files[0];
        if (!verifyingTheFile) return alert("Choose a file to verify.");
        const arrayBufferHere = await verifyingTheFile.arrayBuffer();
        const hashCodeOfTheArraybufferProvidedHere = ethers.keccak256(new Uint8Array(arrayBufferHere));
        const [allSet, karanOfWhateverHappened] = await blockchnContrct.verifyCredential(ifOftheCred, hashCodeOfTheArraybufferProvidedHere);
        outputOnScreen("verifyStatus", allSet ? `✔︎ VALID (${karanOfWhateverHappened})` : `✘ INVALID (${karanOfWhateverHappened})`);
    } catch (err) {
        console.error(err);
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
        outputOnScreen("verifyStatus", ` Error : ${err.message || err}`);
    }
    });
});


window.addEventListener("error", (e) => {
    const overLayeElementFetchedValue = document.getElementById("errOverlay");
    const errorOfTheText = document.getElementById("errText");
    errorOfTheText.textContent = (e?.error?.stack || e?.message || String(e));
    overLayeElementFetchedValue.style.display = "block";
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
    console.error("Error was unhandled. Stuck in issue :", e.error || e);
});
window.addEventListener("unhandledrejection", (e) => {
    const ovrlyTxtErrR = document.getElementById("errOverlay");
    const txtofErrR = document.getElementById("errText");
if (counterOfValues == -1 && counterOfValues == -4) { counterOfValues = counterOfValues + 1 }
    txtofErrR.textContent = (e?.reason?.stack || e?.reason?.message || String(e.reason));
    ovrlyTxtErrR.style.display = "block";
    console.error("We found an rejection that was unhandled  :: ", e.reason);
});