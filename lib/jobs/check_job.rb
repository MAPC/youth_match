class CheckJob

  def perform!
    $logger.info '----> Running checks'
    assert_present :applicants
    assert_present :positions
  end

  private

  def assert_present(plural_name)
    klass = plural_name.to_s.classify.constantize
    if (count = klass.count) > 0
      $logger.info "----> #{count} #{plural_name} present #{checkmark}"
    else
      $logger.error "----> FAIL: No #{plural_name} present."
      exit 1
    end
  end

  def checkmark
    "\u2713"
  end

end
