# koyeb-tailscale-ssh
ขั้นตอนการใช้งานแบบทีละก้าว (หลังคุณ push โค้ดขึ้น GitHub)
	1.	สร้าง Tailscale pre-auth key
	•	เข้า https://login.tailscale.com → Admin Console → Settings → Keys (หรือเมนูเดียวกัน) → สร้าง Pre-auth key แบบ Reusable หรือ Ephemeral ตามต้องการ
	•	คัดลอกค่า TAILSCALE_AUTHKEY
หมายเหตุ: ถ้าใช้บัญชี Tailscale ที่เป็นองค์กร/ทีม คุณจะเห็นตัวเลือก “pre-authorized keys” — สร้าง key ที่มีสิทธิ์ให้เครื่องเข้า tailnet
	2.	สร้าง SSH key (บน iPhone)
	•	ใน iPhone ให้ใช้แอป Termius / Blink / iSH หรือเครื่องอื่นเพื่อสร้าง key pair (หรือสร้างบนคอมถ้ามี)
	•	คัดลอก public key (เช่น ssh-rsa AAAA... you@device) แล้วใส่ลงเป็นค่า SSH_PUBKEY ใน Koyeb (ถ้าต้องการ SSH)
	3.	Deploy บน Koyeb
	•	เข้า Koyeb Console → Create App → เลือก Deploy from Git → ใส่ URL รีโปของคุณ (ที่มี Dockerfile ข้างต้น)
	•	ในหน้า Environment / Secrets ของ Koyeb ให้เพิ่ม:
	•	TAILSCALE_AUTHKEY = (ค่าที่ได้จาก step 1)
	•	SSH_PUBKEY = (ค่าจาก step 2) — ถ้าอยาก SSH
	•	HOSTNAME = (อันนี้ optional เช่น my-phone-server)
	•	กด Deploy
	4.	ตรวจสอบว่าเครื่องเข้าร่วม Tailnet แล้ว
	•	ดู logs ใน Koyeb (app → logs) คุณจะเห็นข้อความจาก tailscale up และ tailscale ip -4 — คัดลอก IP (เช่น 100.x.y.z)
	•	ใน Tailscale Admin → Machines คุณจะเห็นเครื่องใหม่ขึ้นชื่อที่คุณตั้ง (HOSTNAME)
	5.	เชื่อมจาก iPhone
	•	ติดตั้งแอป Tailscale บน iPhone → ล็อกอินด้วยบัญชีเดียวกับที่สร้าง auth key (หรือบัญชีที่มีสิทธิ์ในทีม)
	•	เปิดแอป Tailscale — คุณจะเห็นเครื่อง Koyeb ปรากฏในรายการ (และ IP ของมัน)
	•	เปิด SSH client บน iPhone (Termius/Blink) → สร้าง connection → host = 100.x.y.z (tailscale IP), user = root, auth = private key ที่คุณเก็บบน iPhone
	•	เชื่อมต่อ — เสร็จ!
