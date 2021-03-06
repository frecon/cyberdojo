/*global $,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";
  
  cd.loadFile = function(filename) {
    // I want to
    //    1. restore scrollTop and scrollLeft positions
    //    2. restore focus (also restores cursor position)
    // Restoring the focus loses the scrollTop/Left
    // positions so I have to save them in the dom so
    // I can set the back _after_ the call to focus()
    // The call to focus() allows you to carry on
    // typing at the point the cursor left off.
    
    cd.saveScrollPosition(cd.currentFilename());
    cd.fileDiv(cd.currentFilename()).hide();
    cd.selectFileInFileList(filename);    
    cd.fileDiv(filename).show();
    
    cd.fileContentFor(filename).focus();
    cd.restoreScrollPosition(filename);
    $('#current_filename').val(filename);
  };
  
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveScrollPosition = function(filename) {
    var fc = cd.fileContentFor(filename);
    var top = fc.scrollTop();
    var left = fc.scrollLeft();
    var div = cd.fileDiv(filename);
    div.attr('scrollTop', top);
    div.attr('scrollLeft', left);
  };
  
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.restoreScrollPosition = function(filename) {
    // Restore the saved scrollTop/Left positions.
    // Note that doing the seemingly equivalent
    //   fc.scrollTop(top);
    //   fc.scrollLeft(left);
    // here does _not_ work. I use animate instead with a
    // very fast duration==1
    var div = cd.fileDiv(filename);
    var top = div.attr('scrollTop') || 0;
    var left = div.attr('scrollLeft') || 0;
    var fc = cd.fileContentFor(filename);    
    fc.animate({scrollTop: top, scrollLeft: left}, 1);
  };
  
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.setRenameAndDeleteButtons = function(filename) {
    var fileOps = $('#file_operations');
    var newFile    = fileOps.find('#new');
    var renameFile = fileOps.find('#rename');
    var deleteFile = fileOps.find('#delete');
    var turnOff = function(node) {
      node.attr('disabled', true);
      node.removeAttr('title');      
    };
    var turnOn = function(node, title) {
      node.removeAttr('disabled');
      node.attr('title', title);      
    };

    newFile.attr('title', 'Create a new file');
    if (cd.cantBeRenamedOrDeleted(filename)) {
      turnOff(renameFile);
      turnOff(deleteFile);
    }
    else {
      turnOn(renameFile, 'Rename the current file');
      turnOn(deleteFile, 'Delete the current file');
    }    
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.cantBeRenamedOrDeleted = function(filename) {
    var filenames = [ 'cyber-dojo.sh', 'output' ];
    return cd.inArray(filename, filenames);
  };
  
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  cd.selectFileInFileList = function(filename) {    
    // Can't do $('radio_' + filename) because filename
    // could contain characters that aren't strictly legal
    // characters in a dom node id
    // NB: This fails if the filename contains a double quote
    var node = $('[id="radio_' + filename + '"]');
    var previousFilename = cd.currentFilename();
    var previous = $('[id="radio_' + previousFilename + '"]');
    cd.radioEntrySwitch(previous, node);
    cd.setRenameAndDeleteButtons(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  cd.radioEntrySwitch = function(previous, current) {
    // Used by the run-tests-page filename radio-list
    // and also the create-page languages/exercises radio-lists
    // and the diff page radio lists
    // See the comment for makeFileListEntry() in
    // cyberdojo-files.js
    
    if (previous !== undefined) {
      previous.parent().removeClass('selected');
    }   
    current.parent().addClass('selected');
    current.attr('checked', 'checked');            
  };
  
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadNextFile = function() {
    var filenames = cd.filenames().sort();
    var index = $.inArray(cd.currentFilename(), filenames);
    var nextFilename = filenames[(index + 1) % filenames.length];
    cd.loadFile(nextFilename);  
  };
    
  return cd;
})(cyberDojo || {}, $);

