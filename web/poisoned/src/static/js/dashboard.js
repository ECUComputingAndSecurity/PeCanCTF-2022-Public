$('#changeFile').on('change', function() {
    document.location.href =  `dashboard.php?file=${this.value}`;
  });