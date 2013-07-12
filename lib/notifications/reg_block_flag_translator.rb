class RegBlockFlagTranslator

  def translate_flags(acad_blk_flag, admin_blk_flag, fin_blk_flag, reg_blk_flag)

    response = {
      needsAction: reg_blk_flag == 'Y',
      blocks: [],
    }

    if response[:needsAction]
      response[:explanation] = 'See <a class="cc-outbound-link" data-ng-href="https://bearfacts.berkeley.edu/bearfacts/">BearFacts</a> for more information.'
    else
      response[:summary] = 'None'
    end

    if acad_blk_flag == "Y"
      response[:blocks].push(
        {
          name: 'Academic',
          summary: 'You have an academic block'
        })
    end

    if admin_blk_flag == "Y"
      response[:blocks].push(
        {
          name: 'Administrative',
          summary: 'You have an administrative block'
        })
    end

    if fin_blk_flag == "Y"
      response[:blocks].push(
        {
          name: 'Financial',
          summary: 'You have a financial block'
        })
    end

    response

  end

end
