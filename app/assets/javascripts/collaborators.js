var Collaborators = {
  init: function () {
    if (!Collaborators.initialized) {
      Collaborators.list = $('#collab-list');
      Collaborators.inputContainer = $('#collab-inputs');
      Collaborators.userToLi = {}
      Collaborators.userToInput = {}
    }
    Collaborators.initialized = true;
  },
  add: function (username, hash) {
    Collaborators.init();
    if (typeof(Collaborators.userToLi[username]) != 'undefined') {
      return;
    }
    var li = $('<li><img src="http://gravatar.com/avatar/' + hash + '?s=20&d=identicon"/> ' + username + ' (<a href="javascript:Collaborators.remove(' + "'"+username+"'" + '); return false;">remove</a>)</li>');
    li.appendTo(this.list);
    Collaborators.userToLi[username] = li;
    var input = $('<input type="hidden" name="collaborators[]" value="' + username + '"/>');
    Collaborators.userToInput[username] = input;
    input.appendTo(this.inputContainer);
  },
  remove: function (username) {
    Collaborators.init();
    Collaborators.userToLi[username].remove();
    Collaborators.userToInput[username].remove();
    delete Collaborators.userToLi[username];
    delete Collaborators.userToInput[username];
  }
};
