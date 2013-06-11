var Collaborators = {
  init: function () {
    if (!Collaborators.initialized) {
      Collaborators.list = $('#collab-list');
      Collaborators.inputContainer = $('#collab-inputs');
      Collaborators.emailToLi = {}
      Collaborators.emailToInput = {}
    }
    Collaborators.initialized = true;
  },
  add: function (email) {
    Collaborators.init();
    if (typeof(Collaborators.emailToLi[email]) != 'undefined') {
      return;
    }
    var hash = String(CryptoJS.MD5(email.toLowerCase()));
    var li = $('<li><img src="http://gravatar.com/avatar/' + hash + '?s=20"/> ' + email + ' (<a href="javascript:Collaborators.remove(' + "'"+email+"'" + '); return false;">remove</a>)</li>');
    li.appendTo(this.list);
    Collaborators.emailToLi[email] = li;
    var input = $('<input type="hidden" name="collaborators[]" value="' + email + '"/>');
    Collaborators.emailToInput[email] = input;
    input.appendTo(this.inputContainer);
  },
  remove: function (email) {
    Collaborators.init();
    Collaborators.emailToLi[email].remove();
    Collaborators.emailToInput[email].remove();
    delete Collaborators.emailToLi[email];
    delete Collaborators.emailToInput[email];
  }
};
