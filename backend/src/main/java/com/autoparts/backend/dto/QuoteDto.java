package com.autoparts.backend.dto;

import com.autoparts.backend.domain.enums.QuoteStatus;
import lombok.*;
import java.util.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuoteDto {
    private Long id;
    private Long clientId;
    private String clientEmail;
    private String message;
    private QuoteStatus status;
    private Date requestDate;
}
