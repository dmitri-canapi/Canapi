({
    formatPhoneNumber: function(component, phone) {
        console.log(phone);
        /*var s2 = (""+phone).replace(/\D/g, '');
        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        return (!m) ? null : "(" + m[1] + ") " + m[2] + "-" + m[3];*/
        var numbers = phone.replace(/\D/g, ''),
            char = {0:'(',3:') ',6:'-'};
        phone = '';
        for (var i = 0; i < numbers.length; i++) {
            phone += (char[i]||'') + numbers[i];
        }
        return phone;
    }
})