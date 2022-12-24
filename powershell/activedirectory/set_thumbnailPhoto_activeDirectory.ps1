# Fontes
# http://matthewyarlett.blogspot.com/2013/08/add-or-update-user-profile-picture.html
# https://social.technet.microsoft.com/wiki/contents/articles/19028.active-directory-add-or-update-a-user-picture-using-powershell.aspx


# Atualiza a fotografia no Active Directory
Set-ADUser username -Replace @{thumbnailPhoto=([byte[]](Get-Content "C:\temp\username.jpg" -Encoding byte))}

