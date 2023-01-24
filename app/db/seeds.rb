# username  (passwd)
# yu1hpa    (yu1hpa)
# diplo     (abcd)
# suzuki    (qwert)
users = [
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', username: 'yu1hpa', passwd: 'f32d6fedd58842e63e39f7f6a67ee6712f37d9566e399754d5588908f281c0a8', email: 'yu1hpa@baarcari.dev' },
  { user_id: '6ad0a142-8b05-4d1b-be4c-9c0a43ab4d1c', username: 'diplo', passwd: '88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589', email: 'diplo@baarcari.dev' },
  { user_id: '0a81033d-440d-4f8f-aae2-78df017fd835', username: 'suzuki', passwd: '9e69e7e29351ad837503c44a5971edebc9b7e6d8601c89c284b1b59bf37afa80', email: 'suzuki@baarcari.dev' }
]

users.each do |u|
  User.create(u)
end

# 出品物
exhibition_objs = [
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', item_id: 'aad13b0f-c93f-4876-9c12-eaf70d488417', item_name: 'epson printer', item_info: 'The printer released in 2013', item_image_fname: "", remarks: 'It\'s old', joutosaki: 'hayaimono', deadline: '2023-01-15 03:11:56.377546 +0900' },
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', item_id: '9eaa4ebd-8c53-41f8-8429-660ddb1844fe', item_name: 'Nintendo 3D', item_info: 'The Nintendo 3D released in 2012', item_image_fname: "", remarks: 'It\'s broken', joutosaki: 'lottery', deadline: '2023-01-20 03:11:56.377546 +0900' },
  { user_id: '6ad0a142-8b05-4d1b-be4c-9c0a43ab4d1c', item_id: 'c0f1fae9-7ab2-4742-b22f-16a2c8f5137d', item_name: 'iPhone 8', item_info: 'The iPhone 7 released in 20XX', item_image_fname: "", remarks: 'It\'s old and broken, the color is red', joutosaki: 'lottery', deadline: '2023-02-20 04:16:00.000000 +0900' },
  { user_id: '0a81033d-440d-4f8f-aae2-78df017fd835', item_id: 'bb111149-e900-458d-8283-8403efea40f7', item_name: 'Desk', item_info: 'It\'s a desk that\'s been in my house for a long time', item_image_fname: "", remarks: 'The condition is good', joutosaki: 'hayaimono', deadline: '2023-02-15 14:16:00.000000 +0900' }
]

exhibition_objs.each do |eo|
  ExhibitionObjs.create(eo)
end

# applicantion_id : 応募ID（ユニーク）
applicantion = [
  { applicantion_id: 'aa2c2336-5069-46a9-85c5-96e85d87bf26', user_id: '0a81033d-440d-4f8f-aae2-78df017fd835', purchaser_name: '鈴木 太郎', purchaser_email: 'suzuki@baarcari.dev', exobj_item_id: 'aad13b0f-c93f-4876-9c12-eaf70d488417', is_application_closed: 'Closed'},
  { applicantion_id: 'bd3f61f6-339f-4766-95a7-da66fbbc5077', user_id: '0a81033d-440d-4f8f-aae2-78df017fd835', purchaser_name: '鈴木 太郎', purchaser_email: 'suzuki@baarcari.dev', exobj_item_id: 'bb111149-e900-458d-8283-8403efea40f7', is_application_closed: 'Open'},
  { applicantion_id: '79292524-2969-4a4d-8c7e-f8a0e03bc033', user_id: '6ad0a142-8b05-4d1b-be4c-9c0a43ab4d1c', purchaser_name: 'diplo', purchaser_email: 'diplo@baarcari.dev', exobj_item_id: 'aad13b0f-c93f-4876-9c12-eaf70d488417', is_application_closed: 'Closed' },
  { applicantion_id: 'd8a1ecb1-5b8f-4b72-b9e7-136dbf56b6af', user_id: '6ad0a142-8b05-4d1b-be4c-9c0a43ab4d1c', purchaser_name: 'diplo', purchaser_email: 'diplo@baarcari.dev', exobj_item_id: '9eaa4ebd-8c53-41f8-8429-660ddb1844fe', is_application_closed: 'Closed' },
  { applicantion_id: 'dfd235c1-d595-4677-8fc7-8dde3e108578', user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', purchaser_name: 'yu1hpa', purchaser_email: 'yu1hpa@baarcari.dev', exobj_item_id: 'bb111149-e900-458d-8283-8403efea40f7', is_application_closed: 'Open' }
]

applicantion.each do |a|
  Applicant.create(a)
end