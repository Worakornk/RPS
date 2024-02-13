204498 วิศวกรรมบล๊อกเชน

การบ้านที่ 3

กําหนดส่ง: 13 กุมภาพันธ์ 2567 ก่อนเที่ยงคืน

ในการบ้านนี้เราจะมาเขียน smart contract โดยใช้ Solidity โดย smart contract นี้ผู้ใช้งานสามารถเล่นพนันในเกมส์ที่มีกฏเกณฑ์การแพ้ ชนะ และเสมอ ตายตัว และจะมีการจ่ายเงิน ETH ไปให้กับผู้ที่ชนะ หรือแบ่งเงินในกรณีเสมอ โดยอัตโนมัติ การ compile deploy และทดสอบตัว smart contrat จะทำผ่าน VM บน Remix IDE ที่สามารถเข้าใช้งานได้จากลิงค์ต่อไปนี้
https://remix.ethereum.org/


เริ่มต้นจากการศึกษาโค้ดสำหรับเกมส์พนัน Rock-Paper-Scissors (RPS) จากลิงค์ต่อไปนี้
https://github.com/parujr/RPS/blob/main/RPS.sol


วิดิโอการสอนที่มีการอธิบายและอภิปรายเกี่ยวกับโค้ดนี้ดูได้จากลิงค์ต่อไปนี้
https://ku-edu.webex.com/ku-edu/ldr.php?RCID=eca90c62c633dc7be0d4a838c1b49fe4



จากโค้ด RPS เราจะเห็นได้ว่ามันมีข้อบกพร่องด้านความปลอดภัยและความไม่สะดวกในการใช้งานดังต่อไปนี้
ไม่มีใครอยากจะเลือกก่อน เพราะว่ากลัวถูกอีกคนทำ front-running (การได้ประโยชน์จากการรู้ล่วงหน้าว่าคนหนึ่งเลือกอะไร)
ยากต่อการจะรู้ว่าเราใคร account ไหนเป็น idx ที่ 0 หรือ 1
เงินของ player 0 อาจถูกล๊อกไว้ ถ้าไม่มี player 1 มาลงขันต่อ
กรณีได้ player ทั้ง 2 แล้ว แต่มีเพียง player เดียวที่ลง choice มา แต่อีก player ไม่ยอมเรียก input function เพื่อส่ง choice มาให้ smart contract ได้ตัดสินแพ้ ชนะ เสมอ เช่นนี้ทำให้เงิน ETH ของทุกคนที่ลงขันมาถูกล็อกไว้โดยไม่มีใครถอนออกมาได้
ทำยังไงให้ contract นี้(มีการ transact กับมัน) ได้ในหลายๆ รอบโดยที่ไม่ต้องมีการ deploy ใหม่เสมอในทุกๆครั้งที่ต้องการเล่น


สิ่งที่ต้องทำ
Clone ตัว RPS github repo จากลิงค์ด้านบน แล้วทำการดัดแปลงโค้ด Solidity เพื่อแก้ปัญหาทั้ง 5 ข้อที่ได้กล่าวมา
แก้ปัญหา front-running โดยใช้กระบวนการ commit-reveal (ตามที่เราได้คุยกันในเลคเชอร์เรื่อง cryptography) ขอให้ใช้โค้ด commit-reveal ที่ให้มาโดย import เข้ามาในโค้ด RPS หลัก เมื่อแก้ปัญหานี้ได้แล้ว ให้ทำ git commit แล้วเขียน commit message ที่เหมาะสม
แก้ปัญหาการล๊อกเงิน ETH ที่ player ลงขันเข้ามา ให้กำหนดระยะเวลาว่าหลังจาก X minutes (หรือ hours หรือ days) ผ่านไปหลังจาก block.timestamp ที่มีการเรียก transaction ที่เกี่ยวข้อง ให้คืนเงิน ETH กลับไปให้ผู้เล่น หรือลงโทษผู้เล่นที่ไม่ทำตามกติกาโดยนำเงิน ETH ทั้งหมดให้กับผู้เล่นที่ทำตามกติกา เมื่อแก้ปัญหานี้ได้แล้ว ให้ทำ git commit แล้วเขียน commit message ที่เหมาะสม
ทำให้เกมส์มีความซับซ้อนมากยิ่งขึ้น โดยแทนที่จะมีตัวเลือกแค่ Rock Paper และ Scissors 
เราจะเป็นเกมส์ที่มีตัวเลือก 7 ตัว Rock Water Air Paper Sponge Scissors และ Fire 

โดยมีกฏเกณฑ์การแพ้ ชนะ ดังต่อไปนี้
ROCK POUNDS OUT FIRE, CRUSHES SCISSORS & SPONGE.
FIRE MELTS SCISSORS, BURNS PAPER & SPONGE.
SCISSORS SWISH THROUGH AIR, CUT PAPER & SPONGE.
SPONGE SOAKS PAPER, USES AIR POCKETS, ABSORBS WATER.
PAPER FANS AIR, COVERS ROCK, FLOATS ON WATER.
AIR BLOWS OUT FIRE, ERODES ROCK, EVAPORATES WATER.
WATER ERODES ROCK, PUTS OUT FIRE, RUSTS SCISSORS.

เปลี่ยนชื่อ contract และไฟล์จาก RPS(.sol)  เป็น RWAPSSF(.sol) หลังจากดัดแปลงโค้ด เปลี่ยนชื่อ contract และไฟล์ให้เหมาะสมแล้ว ให้ทำ git commit แล้วเขียน commit message ที่เหมาะสม
สร้างไฟล์ README.md เพื่ออธิบายแนวทางในการแก้ปัญหาความปลอดภัยและปรับปรุงโค้ดเดิมที่ให้มา และให้จับตัวอย่าง screenshot แสดงการทดสอบกรณที่มีผู้แพ้ชนะ และกรณีเสมอ

การส่งงาน
ส่งลิงค์ Github repo ของ contract RWAPSSF มาที่ Google Classroom ของวิชาก่อนกําหนดส่ง โดย commit ล่าสุดจะต้องมี timestamp น้อยกว่าเวลากำหนดส่ง
Export README.md เป็น README.pdf และแนบไฟล์ pdf นี้ส่งมาด้วย

-------------------------------------------------------------

ในส่วนของ Struct Player ได้เพิ่ม
bool isPlayed;
เพื่อดูว่า


